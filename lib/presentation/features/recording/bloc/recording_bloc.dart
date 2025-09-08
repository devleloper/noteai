import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/recording/start_recording.dart';
import '../../../../domain/usecases/recording/stop_recording.dart';
import '../../../../domain/usecases/recording/get_recordings.dart';
import '../../../../domain/usecases/usecase.dart';
import 'recording_event.dart';
import 'recording_state.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final StartRecording _startRecording;
  final StopRecording _stopRecording;
  final GetRecordings _getRecordings;
  
  RecordingBloc({
    required StartRecording startRecording,
    required StopRecording stopRecording,
    required GetRecordings getRecordings,
  }) : _startRecording = startRecording,
       _stopRecording = stopRecording,
       _getRecordings = getRecordings,
       super(RecordingInitial()) {
    
    on<StartRecordingRequested>(_onStartRecordingRequested);
    on<StopRecordingRequested>(_onStopRecordingRequested);
    on<PauseRecordingRequested>(_onPauseRecordingRequested);
    on<ResumeRecordingRequested>(_onResumeRecordingRequested);
    on<LoadRecordingsRequested>(_onLoadRecordingsRequested);
    on<DeleteRecordingRequested>(_onDeleteRecordingRequested);
    on<RecordingProgressUpdated>(_onRecordingProgressUpdated);
  }
  
  void _onStartRecordingRequested(
    StartRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    emit(RecordingLoading());
    
    final result = await _startRecording(StartRecordingParams(title: event.title));
    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (recording) => emit(RecordingInProgress(
        recordingId: recording.id,
        title: recording.title,
        duration: recording.duration,
        amplitude: 0.0,
      )),
    );
  }
  
  void _onStopRecordingRequested(
    StopRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    emit(RecordingLoading());
    
    final result = await _stopRecording(StopRecordingParams(recordingId: event.recordingId));
    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (_) {
        // TODO: Load the completed recording
        emit(RecordingInitial());
      },
    );
  }
  
  void _onPauseRecordingRequested(
    PauseRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    // TODO: Implement pause recording logic
    if (state is RecordingInProgress) {
      final currentState = state as RecordingInProgress;
      emit(RecordingPaused(
        recordingId: currentState.recordingId,
        title: currentState.title,
        duration: currentState.duration,
      ));
    }
  }
  
  void _onResumeRecordingRequested(
    ResumeRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    // TODO: Implement resume recording logic
    if (state is RecordingPaused) {
      final currentState = state as RecordingPaused;
      emit(RecordingInProgress(
        recordingId: currentState.recordingId,
        title: currentState.title,
        duration: currentState.duration,
        amplitude: 0.0,
      ));
    }
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
    // TODO: Implement delete recording logic
    add(LoadRecordingsRequested());
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
