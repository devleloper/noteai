import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../datasources/local/realm_datasource.dart';
import '../datasources/local/audio_recording_service.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../models/recording_model.dart';
import '../../core/services/sync/cross_device_sync_service.dart';
import '../../core/services/sync/firestore_sync_manager.dart';
import '../../core/services/sync/smart_cache.dart';
import '../../core/services/sync/offline_queue.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  final RealmDataSource localDataSource;
  final FirebaseDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AudioRecordingService audioService;
  final CrossDeviceSyncService syncService;
  final FirestoreSyncManager firestoreSyncManager;
  final SmartCache smartCache;
  final OfflineQueue offlineQueue;
  
  RecordingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.audioService,
    required this.syncService,
    required this.firestoreSyncManager,
    required this.smartCache,
    required this.offlineQueue,
  });
  
  @override
  Future<Either<Failure, Recording>> startRecording(String title) async {
    try {
      // Initialize audio service if needed
      if (!audioService.isRecording) {
        await audioService.initialize();
      }
      
      // Generate auto-title if title is empty
      final finalTitle = title.trim().isEmpty 
          ? _generateAutoTitle() 
          : title;
      
      // Start recording
      final audioPath = await audioService.startRecording(finalTitle);
      
      // Create recording entity
      final recording = Recording(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: finalTitle,
        audioPath: audioPath,
        duration: Duration.zero,
        createdAt: DateTime.now(),
        status: RecordingStatus.recording,
        progress: 0.0,
        isSynced: false,
        transcriptionStatus: TranscriptionStatus.notStarted,
      );
      
      // Save to local database
      final model = RecordingModel.fromEntity(recording);
      await localDataSource.saveRecording(model);
      
      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.uploadRecording(model);
          // Update sync status
          final syncedModel = RecordingModel(
            id: model.id,
            title: model.title,
            audioPath: model.audioPath,
            duration: model.duration,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            status: model.status,
            progress: model.progress,
            transcript: model.transcript,
            summary: model.summary,
            isSynced: true,
            transcriptionStatus: model.transcriptionStatus,
            transcriptionCompletedAt: model.transcriptionCompletedAt,
            transcriptionError: model.transcriptionError,
          );
          await localDataSource.updateRecording(syncedModel);
        } catch (e) {
          print('Failed to sync recording to remote: $e');
          // Don't fail the operation, just log the error
        }
      }
      
      return Right(recording);
    } catch (e) {
      return Left(RecordingFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> stopRecording(String recordingId) async {
    try {
      // Stop audio recording
      await audioService.stopRecording();
      
      // Get final duration before resetting
      final finalDuration = audioService.finalRecordingDuration;
      
      // Get current recording from database
      final existingRecording = await localDataSource.getRecording(recordingId);
      if (existingRecording == null) {
        return Left(RecordingFailure('Recording not found'));
      }
      
      // Update recording with final duration and status
      final updatedRecording = RecordingModel(
        id: existingRecording.id,
        title: existingRecording.title,
        audioPath: existingRecording.audioPath,
        duration: finalDuration,
        createdAt: existingRecording.createdAt,
        updatedAt: DateTime.now(),
        status: RecordingStatus.completed,
        progress: existingRecording.progress,
        transcript: existingRecording.transcript,
        summary: existingRecording.summary,
        isSynced: existingRecording.isSynced,
        transcriptionStatus: existingRecording.transcriptionStatus,
        transcriptionCompletedAt: existingRecording.transcriptionCompletedAt,
        transcriptionError: existingRecording.transcriptionError,
      );
      
      // Save updated recording
      await localDataSource.updateRecording(updatedRecording);
      
      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateRecording(updatedRecording);
          // Update sync status
          final syncedRecording = RecordingModel(
            id: updatedRecording.id,
            title: updatedRecording.title,
            audioPath: updatedRecording.audioPath,
            duration: updatedRecording.duration,
            createdAt: updatedRecording.createdAt,
            updatedAt: updatedRecording.updatedAt,
            status: updatedRecording.status,
            progress: updatedRecording.progress,
            transcript: updatedRecording.transcript,
            summary: updatedRecording.summary,
            isSynced: true,
            transcriptionStatus: updatedRecording.transcriptionStatus,
            transcriptionCompletedAt: updatedRecording.transcriptionCompletedAt,
            transcriptionError: updatedRecording.transcriptionError,
          );
          await localDataSource.updateRecording(syncedRecording);
        } catch (e) {
          print('Failed to sync recording update to remote: $e');
          // Don't fail the operation, just log the error
        }
      }
      
      // Reset audio service state for next recording
      audioService.resetRecordingState();
      
      return const Right(null);
    } catch (e) {
      return Left(RecordingFailure(e.toString()));
    }
  }
  
  
  @override
  Future<Either<Failure, List<Recording>>> getRecordings() async {
    try {
      print('RecordingRepository: Loading recordings...');
      
      // Get local recordings
      final localRecordings = await localDataSource.getRecordings();
      print('RecordingRepository: Found ${localRecordings.length} local recordings');
      
      // Get synced recordings from cache first
      final cachedRecordings = await smartCache.getAllCachedTranscripts();
      print('RecordingRepository: Found ${cachedRecordings.length} cached recordings');
      
      // Get remote recordings if online
      List<Map<String, dynamic>> remoteRecordings = [];
      List<Map<String, dynamic>> remoteChatSessions = [];
      if (await networkInfo.isConnected) {
        try {
          print('RecordingRepository: Fetching remote recordings...');
          remoteRecordings = await firestoreSyncManager.getTranscripts();
          print('RecordingRepository: Found ${remoteRecordings.length} remote recordings');
          
          print('RecordingRepository: Fetching remote chat sessions...');
          remoteChatSessions = await firestoreSyncManager.getChats();
          print('RecordingRepository: Found ${remoteChatSessions.length} remote chat sessions');
        } catch (e) {
          print('RecordingRepository: Error fetching remote data: $e');
        }
      } else {
        print('RecordingRepository: Offline - skipping remote fetch');
      }
      
      // Merge local and remote recordings
      final allRecordings = <Recording>[];
      
      // Add local recordings
      for (final model in localRecordings) {
        allRecordings.add(model.toEntity());
      }
      
      // Add remote recordings (metadata only, audio files remain local)
      for (final remoteData in remoteRecordings) {
        final recordingId = remoteData['recordingId'] as String?;
        if (recordingId != null && !allRecordings.any((r) => r.id == recordingId)) {
          // Create remote recording entity (audio file not available locally)
          final remoteRecording = Recording(
            id: recordingId,
            title: remoteData['title'] as String? ?? 'Remote Recording',
            audioPath: '', // No local file path
            duration: Duration(milliseconds: remoteData['duration'] as int? ?? 0),
            createdAt: DateTime.tryParse(remoteData['createdAt'] as String? ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(remoteData['updatedAt'] as String? ?? '') ?? DateTime.now(),
            status: RecordingStatus.completed,
            progress: 1.0,
            isSynced: true,
            transcriptionStatus: remoteData['transcriptionStatus'] == 'completed' 
                ? TranscriptionStatus.completed 
                : TranscriptionStatus.pending,
            transcript: remoteData['transcript'] as String?,
            summary: remoteData['summary'] as String?,
            isRemote: true, // Mark as remote recording
            deviceId: remoteData['deviceId'] as String?,
          );
          allRecordings.add(remoteRecording);
          print('RecordingRepository: Added remote recording $recordingId');
        }
      }
      
      // Sort by creation date, most recent first
      allRecordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Sync remote chat sessions to local database
      for (final chatData in remoteChatSessions) {
        try {
          print('RecordingRepository: Processing chat data: $chatData');
          final chatId = chatData['chatId'] as String?;
          final recordingId = chatData['recordingId'] as String?;
          if (chatId != null && recordingId != null) {
            // Check if chat session already exists locally
            final existingSession = await localDataSource.getChatSessionByRecordingId(recordingId);
            if (existingSession == null) {
              // Create local chat session from remote data
              await localDataSource.createChatSessionFromRemote(chatData);
              print('RecordingRepository: Synced chat session $chatId for recording $recordingId');
              
              // Also sync chat messages if they exist
              try {
                final messages = await firestoreSyncManager.getChatMessages(recordingId);
                if (messages.isNotEmpty) {
                  await localDataSource.createChatMessagesFromRemote(recordingId, messages);
                  print('RecordingRepository: Synced ${messages.length} messages for chat session $chatId');
                }
              } catch (e) {
                print('RecordingRepository: Error syncing chat messages: $e');
              }
            } else {
              print('RecordingRepository: Chat session already exists for recording $recordingId');
            }
          } else {
            print('RecordingRepository: Missing chatId or recordingId in chat data');
          }
        } catch (e) {
          print('RecordingRepository: Error syncing chat session: $e');
        }
      }
      
      return Right(allRecordings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Recording>> getRecording(String id) async {
    try {
      final recording = await localDataSource.getRecording(id);
      if (recording == null) {
        return Left(ServerFailure('Recording not found'));
      }
      return Right(recording.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  
  @override
  Future<Either<Failure, void>> updateRecording(Recording recording) async {
    try {
      final model = RecordingModel.fromEntity(recording);
      await localDataSource.updateRecording(model);
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateRecording(model);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> syncRecording(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final recording = await localDataSource.getRecording(id);
        if (recording != null) {
          await remoteDataSource.uploadRecording(recording);
        }
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
  
  @override
  Future<Either<Failure, List<Recording>>> getPendingSyncRecordings() async {
    try {
      final recordings = await localDataSource.getRecordings();
      final pendingSync = recordings.where((r) => !r.isSynced).toList();
      return Right(pendingSync.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteRecording(String id) async {
    try {
      // Get recording to access audio file path
      final recording = await localDataSource.getRecording(id);
      if (recording == null) {
        return Left(RecordingFailure('Recording not found'));
      }
      
      // Delete from local database
      await localDataSource.deleteRecording(id);
      
      // Delete audio file from file system
      if (recording.audioPath.isNotEmpty) {
        final file = File(recording.audioPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Delete from remote database if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteRecording(id);
        } catch (e) {
          // Log error but don't fail the operation since local deletion succeeded
          print('Failed to delete from remote: $e');
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(RecordingFailure('Failed to delete recording: $e'));
    }
  }
  
  String _generateAutoTitle() {
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return '$date | $time';
  }
  
  @override
  Future<Either<Failure, Recording>> startTranscription(String recordingId) async {
    try {
      // Get recording from local database
      final recording = await localDataSource.getRecording(recordingId);
      if (recording == null) {
        return Left(RecordingFailure('Recording not found'));
      }
      
      // Update transcription status to pending
      final updatedRecording = RecordingModel(
        id: recording.id,
        title: recording.title,
        audioPath: recording.audioPath,
        duration: recording.duration,
        createdAt: recording.createdAt,
        updatedAt: DateTime.now(),
        status: recording.status,
        progress: recording.progress,
        transcript: recording.transcript,
        summary: recording.summary,
        isSynced: recording.isSynced,
        transcriptionStatus: TranscriptionStatus.pending,
        transcriptionCompletedAt: recording.transcriptionCompletedAt,
        transcriptionError: recording.transcriptionError,
      );
      
      // Save to local database
      await localDataSource.updateRecording(updatedRecording);
      
      return Right(updatedRecording.toEntity());
    } catch (e) {
      return Left(RecordingFailure('Failed to start transcription: $e'));
    }
  }
  
  @override
  Future<Either<Failure, Recording>> updateTranscription(
    String recordingId,
    String? transcript,
    TranscriptionStatus transcriptionStatus,
    String? transcriptionError,
  ) async {
    try {
      // Get recording from local database
      final recording = await localDataSource.getRecording(recordingId);
      if (recording == null) {
        return Left(RecordingFailure('Recording not found'));
      }
      
      // Update transcription data
      final updatedRecording = RecordingModel(
        id: recording.id,
        title: recording.title,
        audioPath: recording.audioPath,
        duration: recording.duration,
        createdAt: recording.createdAt,
        updatedAt: DateTime.now(),
        status: recording.status,
        progress: recording.progress,
        transcript: transcript,
        summary: recording.summary,
        isSynced: recording.isSynced,
        transcriptionStatus: transcriptionStatus,
        transcriptionCompletedAt: transcriptionStatus == TranscriptionStatus.completed 
            ? DateTime.now() 
            : recording.transcriptionCompletedAt,
        transcriptionError: transcriptionError,
      );
      
      // Save to local database
      await localDataSource.updateRecording(updatedRecording);
      
      // Sync to remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateRecording(updatedRecording);
          final syncedRecording = RecordingModel(
            id: updatedRecording.id,
            title: updatedRecording.title,
            audioPath: updatedRecording.audioPath,
            duration: updatedRecording.duration,
            createdAt: updatedRecording.createdAt,
            updatedAt: updatedRecording.updatedAt,
            status: updatedRecording.status,
            progress: updatedRecording.progress,
            transcript: updatedRecording.transcript,
            summary: updatedRecording.summary,
            isSynced: true,
            transcriptionStatus: updatedRecording.transcriptionStatus,
            transcriptionCompletedAt: updatedRecording.transcriptionCompletedAt,
            transcriptionError: updatedRecording.transcriptionError,
          );
          await localDataSource.updateRecording(syncedRecording);
          return Right(syncedRecording.toEntity());
        } catch (e) {
          // Continue with local update even if sync fails
          print('Failed to sync transcription update: $e');
        }
      }
      
      return Right(updatedRecording.toEntity());
    } catch (e) {
      return Left(RecordingFailure('Failed to update transcription: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<Recording>>> getPendingTranscriptions() async {
    try {
      final recordings = await localDataSource.getRecordings();
      final pendingTranscriptions = recordings
          .where((recording) => 
              recording.transcriptionStatus == TranscriptionStatus.pending ||
              recording.transcriptionStatus == TranscriptionStatus.processing)
          .map((recording) => recording.toEntity())
          .toList();
      
      return Right(pendingTranscriptions);
    } catch (e) {
      return Left(RecordingFailure('Failed to get pending transcriptions: $e'));
    }
  }
}
