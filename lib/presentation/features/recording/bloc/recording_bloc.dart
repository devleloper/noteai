import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/recording/start_recording.dart';
import '../../../../domain/usecases/recording/stop_recording.dart';
import '../../../../domain/usecases/recording/get_recordings.dart';
import '../../../../domain/usecases/recording/delete_recording.dart';
import '../../../../domain/usecases/transcription/start_transcription.dart';
import '../../../../domain/usecases/transcription/update_transcription.dart';
import '../../../../data/datasources/remote/transcription_service.dart';
import '../../../../domain/entities/recording.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../domain/usecases/usecase.dart';
import '../../../../data/datasources/local/audio_recording_service.dart';
import '../../../../core/utils/service_locator.dart' as di;
import 'recording_event.dart';
import 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final StartRecording _startRecording;
  final StopRecording _stopRecording;
  final GetRecordings _getRecordings;
  final DeleteRecording _deleteRecording;
  final StartTranscription _startTranscription;
  final UpdateTranscription _updateTranscription;
  final AudioRecordingService _audioService;
  final TranscriptionService _transcriptionService;
  StreamSubscription<RecordingData>? _recordingSubscription;
  
  RecordingBloc({
    required StartRecording startRecording,
    required StopRecording stopRecording,
    required GetRecordings getRecordings,
    required DeleteRecording deleteRecording,
    required StartTranscription startTranscription,
    required UpdateTranscription updateTranscription,
  }) : _startRecording = startRecording,
       _stopRecording = stopRecording,
       _getRecordings = getRecordings,
       _deleteRecording = deleteRecording,
       _startTranscription = startTranscription,
       _updateTranscription = updateTranscription,
       _audioService = di.sl<AudioRecordingService>(),
       _transcriptionService = di.sl<TranscriptionService>(),
       super(RecordingInitial()) {
    
    on<StartRecordingRequested>(_onStartRecordingRequested);
    on<StopRecordingRequested>(_onStopRecordingRequested);
    on<LoadRecordingsRequested>(_onLoadRecordingsRequested);
    on<DeleteRecordingRequested>(_onDeleteRecordingRequested);
    on<RecordingProgressUpdated>(_onRecordingProgressUpdated);
    on<StartTranscriptionRequested>(_onStartTranscriptionRequested);
    on<TranscriptionProcessingEvent>(_onTranscriptionProcessing);
    on<TranscriptionCompletedEvent>(_onTranscriptionCompleted);
    on<TranscriptionFailedEvent>(_onTranscriptionFailed);
  }
  
  @override
  Future<void> close() {
    _recordingSubscription?.cancel();
    return super.close();
  }
  
  void _onStartRecordingRequested(
    StartRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    emit(RecordingLoading());
    
    final result = await _startRecording(StartRecordingParams(title: event.title));
    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (recording) {
        // Start listening to recording stream for real-time updates
        _recordingSubscription?.cancel();
        _recordingSubscription = _audioService.recordingStream?.listen(
          (recordingData) {
            add(RecordingProgressUpdated(
              recordingId: recording.id,
              duration: recordingData.duration,
              amplitude: recordingData.amplitude,
            ));
          },
          onError: (error) {
            print('Recording stream error: $error');
          },
        );
        
        emit(RecordingInProgress(
          recordingId: recording.id,
          title: recording.title,
          duration: recording.duration,
          amplitude: 0.0,
        ));
      },
    );
  }
  
  void _onStopRecordingRequested(
    StopRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    emit(RecordingLoading());
    
    // Cancel recording stream subscription
    _recordingSubscription?.cancel();
    
    final result = await _stopRecording(StopRecordingParams(recordingId: event.recordingId));
    
    if (result.isLeft()) {
      final failure = result.fold((l) => l, (r) => throw Exception('Unexpected right value'));
      emit(RecordingError(failure.message));
      return;
    }
    
    // Get the completed recording and emit RecordingCompleted state
    final recordingsResult = await _getRecordings(NoParams());
    
    if (recordingsResult.isLeft()) {
      final failure = recordingsResult.fold((l) => l, (r) => throw Exception('Unexpected right value'));
      emit(RecordingError(failure.message));
      return;
    }
    
    final recordings = recordingsResult.fold((l) => throw Exception('Unexpected left value'), (r) => r);
    
    // Find the completed recording
    final completedRecording = recordings.firstWhere(
      (recording) => recording.id == event.recordingId,
      orElse: () => recordings.first,
    );
    
    // Emit the updated recordings list first to ensure data is available
    emit(RecordingsLoaded(recordings));
    
    // Then emit the completion state
    emit(RecordingCompleted(completedRecording));
    
    // Automatically start transcription if internet is available
    _startAutomaticTranscription(completedRecording.id);
  }
  
  
  void _onLoadRecordingsRequested(
    LoadRecordingsRequested event,
    Emitter<RecordingState> emit,
  ) async {
    emit(RecordingLoading());
    
    final result = await _getRecordings(NoParams());
    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (recordings) => emit(RecordingsLoaded(recordings)),
    );
  }
  
  void _onDeleteRecordingRequested(
    DeleteRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    emit(RecordingLoading());
    
    final result = await _deleteRecording(DeleteRecordingParams(recordingId: event.recordingId));
    result.fold(
      (failure) => emit(RecordingError(failure.message ?? 'Unknown error')),
      (_) {
        // Reload recordings after successful deletion
        add(LoadRecordingsRequested());
      },
    );
  }
  
  void _onRecordingProgressUpdated(
    RecordingProgressUpdated event,
    Emitter<RecordingState> emit,
  ) {
    if (state is RecordingInProgress) {
      final currentState = state as RecordingInProgress;
      emit(RecordingInProgress(
        recordingId: currentState.recordingId,
        title: currentState.title,
        duration: event.duration,
        amplitude: event.amplitude,
      ));
    }
  }
  
  void _onStartTranscriptionRequested(
    StartTranscriptionRequested event,
    Emitter<RecordingState> emit,
  ) async {
    print('StartTranscriptionRequested for recording: ${event.recordingId}');
    emit(TranscriptionPending(event.recordingId));
    
    // Use the start transcription use case
    final result = await _startTranscription(StartTranscriptionParams(recordingId: event.recordingId));
    result.fold(
      (failure) {
        print('Failed to start transcription: ${failure.message}');
        emit(TranscriptionError(recordingId: event.recordingId, error: failure.message));
      },
      (recording) {
        print('Transcription started successfully for recording: ${event.recordingId}');
        // Start transcription process
        _processTranscription(event.recordingId);
      },
    );
  }
  
  void _onTranscriptionProcessing(
    TranscriptionProcessingEvent event,
    Emitter<RecordingState> emit,
  ) {
    emit(TranscriptionProcessing(event.recordingId));
  }
  
  void _onTranscriptionCompleted(
    TranscriptionCompletedEvent event,
    Emitter<RecordingState> emit,
  ) async {
    // Update transcription in database
    final result = await _updateTranscription(UpdateTranscriptionParams(
      recordingId: event.recordingId,
      transcript: event.transcript,
      transcriptionStatus: TranscriptionStatus.completed,
    ));
    
    result.fold(
      (failure) => emit(TranscriptionError(
        recordingId: event.recordingId,
        error: failure.message,
      )),
      (recording) {
        emit(TranscriptionCompleted(
          recordingId: event.recordingId,
          transcript: event.transcript,
        ));
        
        // Reload recordings to show updated transcription
        add(LoadRecordingsRequested());
      },
    );
  }
  
  void _onTranscriptionFailed(
    TranscriptionFailedEvent event,
    Emitter<RecordingState> emit,
  ) async {
    // Update transcription error in database
    final result = await _updateTranscription(UpdateTranscriptionParams(
      recordingId: event.recordingId,
      transcriptionStatus: TranscriptionStatus.failed,
      transcriptionError: event.error,
    ));
    
    result.fold(
      (failure) => emit(TranscriptionError(
        recordingId: event.recordingId,
        error: 'Failed to update transcription error: ${failure.message}',
      )),
      (recording) {
        emit(TranscriptionError(
          recordingId: event.recordingId,
          error: event.error,
        ));
        
        // Reload recordings to show updated transcription status
        add(LoadRecordingsRequested());
      },
    );
  }
  
  void _startAutomaticTranscription(String recordingId) async {
    print('Starting automatic transcription for recording: $recordingId');
    
    // Check if transcription service is configured
    final isConfigured = await _transcriptionService.isConfigured();
    print('Transcription service configured: $isConfigured');
    if (!isConfigured) {
      print('Skipping transcription - service not configured');
      return; // Skip transcription if not configured
    }
    
    // Check network connectivity
    final isConnected = await _transcriptionService.isNetworkAvailable;
    print('Network available: $isConnected');
    if (!isConnected) {
      // Queue for later when network is available
      _queueTranscriptionForLater(recordingId);
      return;
    }
    
    // Start transcription process
    print('Starting transcription process');
    add(StartTranscriptionRequested(recordingId));
  }
  
  void _queueTranscriptionForLater(String recordingId) {
    // TODO: Implement offline queue for transcriptions
    // For now, just mark as pending
    print('Transcription queued for later: $recordingId');
  }
  
  void _processTranscription(String recordingId, {int retryCount = 0}) async {
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 2);
    
    try {
      // Get recording to access audio file
      final recordingsResult = await _getRecordings(NoParams());
      if (recordingsResult.isLeft()) {
        add(TranscriptionFailedEvent(
          recordingId: recordingId,
          error: 'Failed to get recording for transcription',
        ));
        return;
      }
      
      final recordings = recordingsResult.fold(
        (l) => throw Exception('Unexpected left value'),
        (r) => r,
      );
      
      final recording = recordings.firstWhere(
        (r) => r.id == recordingId,
        orElse: () => throw Exception('Recording not found'),
      );
      
      // Check if audio file exists
      final audioFile = File(recording.audioPath);
      if (!await audioFile.exists()) {
        add(TranscriptionFailedEvent(
          recordingId: recordingId,
          error: 'Audio file not found',
        ));
        return;
      }
      
      // Update status to processing
      final updateResult = await _updateTranscription(UpdateTranscriptionParams(
        recordingId: recordingId,
        transcriptionStatus: TranscriptionStatus.processing,
      ));
      
      if (updateResult.isLeft()) {
        add(TranscriptionFailedEvent(
          recordingId: recordingId,
          error: 'Failed to update transcription status',
        ));
        return;
      }
      
      // Emit processing state
      add(TranscriptionProcessingEvent(recordingId));
      
      // Perform transcription
      final transcript = await _transcriptionService.transcribeAudio(
        audioFile: audioFile,
      );
      
      // Complete transcription
      add(TranscriptionCompletedEvent(
        recordingId: recordingId,
        transcript: transcript,
      ));
      
    } catch (e) {
      // Check if we should retry
      if (retryCount < maxRetries && _shouldRetry(e)) {
        // Calculate exponential backoff delay
        final delay = Duration(
          milliseconds: baseDelay.inMilliseconds * (1 << retryCount),
        );
        
        // Wait before retrying
        await Future.delayed(delay);
        
        // Retry with incremented count
        _processTranscription(recordingId, retryCount: retryCount + 1);
      } else {
        add(TranscriptionFailedEvent(
          recordingId: recordingId,
          error: e.toString(),
        ));
      }
    }
  }
  
  bool _shouldRetry(dynamic error) {
    if (error is TranscriptionException) {
      final message = error.message.toLowerCase();
      // Retry on network errors, rate limits, and server errors
      return message.contains('network') ||
             message.contains('rate limit') ||
             message.contains('temporarily unavailable') ||
             message.contains('timeout');
    }
    return false;
  }
}
