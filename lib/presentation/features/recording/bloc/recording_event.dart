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


class LoadRecordingsRequested extends RecordingEvent {}

class DeleteRecordingRequested extends RecordingEvent {
  final String recordingId;
  
  const DeleteRecordingRequested(this.recordingId);
  
  @override
  List<Object> get props => [recordingId];
}

class RenameRecordingRequested extends RecordingEvent {
  final String recordingId;
  final String newTitle;
  
  const RenameRecordingRequested({
    required this.recordingId,
    required this.newTitle,
  });
  
  @override
  List<Object> get props => [recordingId, newTitle];
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

class StartTranscriptionRequested extends RecordingEvent {
  final String recordingId;
  
  const StartTranscriptionRequested(this.recordingId);
  
  @override
  List<Object> get props => [recordingId];
}

class TranscriptionCompletedEvent extends RecordingEvent {
  final String recordingId;
  final String transcript;
  
  const TranscriptionCompletedEvent({
    required this.recordingId,
    required this.transcript,
  });
  
  @override
  List<Object> get props => [recordingId, transcript];
}

class TranscriptionFailedEvent extends RecordingEvent {
  final String recordingId;
  final String error;
  
  const TranscriptionFailedEvent({
    required this.recordingId,
    required this.error,
  });
  
  @override
  List<Object> get props => [recordingId, error];
}

class TranscriptionProcessingEvent extends RecordingEvent {
  final String recordingId;
  
  const TranscriptionProcessingEvent(this.recordingId);
  
  @override
  List<Object> get props => [recordingId];
}
