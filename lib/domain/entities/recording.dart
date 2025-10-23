import 'package:equatable/equatable.dart';

class Recording extends Equatable {
  final String id;
  final String title;
  final String audioPath;
  final Duration duration;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final RecordingStatus status;
  final double progress;
  final String? transcript;
  final String? summary;
  final bool isSynced;
  final TranscriptionStatus transcriptionStatus;
  final DateTime? transcriptionCompletedAt;
  final String? transcriptionError;
  final bool isRemote;
  final String? deviceId;
  
  const Recording({
    required this.id,
    required this.title,
    required this.audioPath,
    required this.duration,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.progress,
    this.transcript,
    this.summary,
    required this.isSynced,
    required this.transcriptionStatus,
    this.transcriptionCompletedAt,
    this.transcriptionError,
    this.isRemote = false,
    this.deviceId,
  });
  
  @override
  List<Object?> get props => [
    id,
    title,
    audioPath,
    duration,
    createdAt,
    updatedAt,
    status,
    progress,
    transcript,
    summary,
    isSynced,
    transcriptionStatus,
    transcriptionCompletedAt,
    transcriptionError,
    isRemote,
    deviceId,
  ];
  
  Recording copyWith({
    String? id,
    String? title,
    String? audioPath,
    Duration? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    RecordingStatus? status,
    double? progress,
    String? transcript,
    String? summary,
    bool? isSynced,
    TranscriptionStatus? transcriptionStatus,
    DateTime? transcriptionCompletedAt,
    String? transcriptionError,
    bool? isRemote,
    String? deviceId,
  }) {
    return Recording(
      id: id ?? this.id,
      title: title ?? this.title,
      audioPath: audioPath ?? this.audioPath,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      transcript: transcript ?? this.transcript,
      summary: summary ?? this.summary,
      isSynced: isSynced ?? this.isSynced,
      transcriptionStatus: transcriptionStatus ?? this.transcriptionStatus,
      transcriptionCompletedAt: transcriptionCompletedAt ?? this.transcriptionCompletedAt,
      transcriptionError: transcriptionError ?? this.transcriptionError,
      isRemote: isRemote ?? this.isRemote,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}

enum RecordingStatus {
  recording,
  paused,
  completed,
  processing,
  transcribed,
  failed,
}

enum TranscriptionStatus {
  notStarted,
  pending,
  processing,
  completed,
  failed,
}
