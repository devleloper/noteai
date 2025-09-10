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
