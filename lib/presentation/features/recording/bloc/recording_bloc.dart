import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/recording/start_recording.dart';
import '../../../../domain/usecases/recording/stop_recording.dart';
import '../../../../domain/usecases/recording/get_recordings.dart';
import '../../../../domain/usecases/recording/delete_recording.dart';
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
  final AudioRecordingService _audioService;
  StreamSubscription<RecordingData>? _recordingSubscription;
  
  RecordingBloc({
    required StartRecording startRecording,
    required StopRecording stopRecording,
    required GetRecordings getRecordings,
    required DeleteRecording deleteRecording,
  }) : _startRecording = startRecording,
       _stopRecording = stopRecording,
       _getRecordings = getRecordings,
       _deleteRecording = deleteRecording,
       _audioService = di.sl<AudioRecordingService>(),
       super(RecordingInitial()) {
    
    on<StartRecordingRequested>(_onStartRecordingRequested);
    on<StopRecordingRequested>(_onStopRecordingRequested);
    on<LoadRecordingsRequested>(_onLoadRecordingsRequested);
    on<DeleteRecordingRequested>(_onDeleteRecordingRequested);
    on<RecordingProgressUpdated>(_onRecordingProgressUpdated);
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
    
    emit(RecordingCompleted(completedRecording));
    
    // Also emit the updated recordings list
    emit(RecordingsLoaded(recordings));
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
}
