import 'package:equatable/equatable.dart';
import '../../../../domain/entities/recording.dart';

abstract class RecordingState extends Equatable {
  const RecordingState();

  @override
  List<Object?> get props => [];
}

class RecordingInitial extends RecordingState {}

class RecordingLoading extends RecordingState {}

class RecordingInProgress extends RecordingState {
  final String recordingId;
  final String title;
  final Duration duration;
  final double amplitude;
  
  const RecordingInProgress({
    required this.recordingId,
    required this.title,
    required this.duration,
    required this.amplitude,
  });
  
  @override
  List<Object> get props => [recordingId, title, duration, amplitude];
}


class RecordingCompleted extends RecordingState {
  final Recording recording;
  
  const RecordingCompleted(this.recording);
  
  @override
  List<Object> get props => [recording];
}

class RecordingsLoaded extends RecordingState {
  final List<Recording> recordings;
  
  const RecordingsLoaded(this.recordings);
  
  @override
  List<Object> get props => [recordings];
}

class RecordingError extends RecordingState {
  final String message;
  
  const RecordingError(this.message);
  
  @override
  List<Object> get props => [message];
}

class RecordingRenamed extends RecordingState {
  final String recordingId;
  final String newTitle;
  
  const RecordingRenamed({
    required this.recordingId,
    required this.newTitle,
  });
  
  @override
  List<Object> get props => [recordingId, newTitle];
}

class RecordingRenameError extends RecordingState {
  final String recordingId;
  final String error;
  
  const RecordingRenameError({
    required this.recordingId,
    required this.error,
  });
  
  @override
  List<Object> get props => [recordingId, error];
}

class TranscriptionPending extends RecordingState {
  final String recordingId;
  final List<Recording> recordings;
  
  const TranscriptionPending({
    required this.recordingId,
    required this.recordings,
  });
  
  @override
  List<Object> get props => [recordingId, recordings];
}

class TranscriptionProcessing extends RecordingState {
  final String recordingId;
  final List<Recording> recordings;
  
  const TranscriptionProcessing({
    required this.recordingId,
    required this.recordings,
  });
  
  @override
  List<Object> get props => [recordingId, recordings];
}

class TranscriptionCompleted extends RecordingState {
  final String recordingId;
  final String transcript;
  
  const TranscriptionCompleted({
    required this.recordingId,
    required this.transcript,
  });
  
  @override
  List<Object> get props => [recordingId, transcript];
}

class TranscriptionRegenerating extends RecordingState {
  final String recordingId;
  final List<Recording> recordings;
  
  const TranscriptionRegenerating({
    required this.recordingId,
    required this.recordings,
  });
  
  @override
  List<Object> get props => [recordingId, recordings];
}

class TranscriptionRegenerationCompleted extends RecordingState {
  final String recordingId;
  final String transcript;
  final List<Recording> recordings;
  
  const TranscriptionRegenerationCompleted({
    required this.recordingId,
    required this.transcript,
    required this.recordings,
  });
  
  @override
  List<Object> get props => [recordingId, transcript, recordings];
}

class TranscriptionRegenerationFailed extends RecordingState {
  final String recordingId;
  final String error;
  final List<Recording> recordings;
  
  const TranscriptionRegenerationFailed({
    required this.recordingId,
    required this.error,
    required this.recordings,
  });
  
  @override
  List<Object> get props => [recordingId, error, recordings];
}

class TranscriptionError extends RecordingState {
  final String recordingId;
  final String error;
  
  const TranscriptionError({
    required this.recordingId,
    required this.error,
  });
  
  @override
  List<Object> get props => [recordingId, error];
}

// Stealth Mode States
class StealthActivating extends RecordingState {
  final double progress; // 0.0 to 1.0
  
  const StealthActivating(this.progress);
  
  @override
  List<Object> get props => [progress];
}

class StealthActive extends RecordingState {
  final String recordingId;
  final Duration duration;
  
  const StealthActive({
    required this.recordingId,
    required this.duration,
  });
  
  @override
  List<Object> get props => [recordingId, duration];
}

class StealthDeactivating extends RecordingState {
  final double progress; // 0.0 to 1.0
  
  const StealthDeactivating(this.progress);
  
  @override
  List<Object> get props => [progress];
}
