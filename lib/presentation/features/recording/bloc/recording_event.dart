import 'package:equatable/equatable.dart';

abstract class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object> get props => [];
}

class StartRecordingRequested extends RecordingEvent {
  final String title;
  
  const StartRecordingRequested(this.title);
  
  @override
  List<Object> get props => [title];
}

class StopRecordingRequested extends RecordingEvent {
  final String recordingId;
  
  const StopRecordingRequested(this.recordingId);
  
  @override
  List<Object> get props => [recordingId];
}

class PauseRecordingRequested extends RecordingEvent {
  final String recordingId;
  
  const PauseRecordingRequested(this.recordingId);
  
  @override
  List<Object> get props => [recordingId];
}

class ResumeRecordingRequested extends RecordingEvent {
  final String recordingId;
  
  const ResumeRecordingRequested(this.recordingId);
  
  @override
  List<Object> get props => [recordingId];
}

class LoadRecordingsRequested extends RecordingEvent {}

class DeleteRecordingRequested extends RecordingEvent {
  final String recordingId;
  
  const DeleteRecordingRequested(this.recordingId);
  
  @override
  List<Object> get props => [recordingId];
}

class RecordingProgressUpdated extends RecordingEvent {
  final String recordingId;
  final Duration duration;
  final double amplitude;
  
  const RecordingProgressUpdated({
    required this.recordingId,
    required this.duration,
    required this.amplitude,
  });
  
  @override
  List<Object> get props => [recordingId, duration, amplitude];
}
