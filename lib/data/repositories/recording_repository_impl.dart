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

class RecordingRepositoryImpl implements RecordingRepository {
  final RealmDataSource localDataSource;
  final FirebaseDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final AudioRecordingService audioService;
  
  RecordingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.audioService,
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
      );
      
      // Save to local database
      final model = RecordingModel.fromEntity(recording);
      await localDataSource.saveRecording(model);
      
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
      );
      
      // Save updated recording
      await localDataSource.updateRecording(updatedRecording);
      
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
      final recordings = await localDataSource.getRecordings();
      // Sort by creation date, most recent first
      recordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(recordings.map((model) => model.toEntity()).toList());
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
}
