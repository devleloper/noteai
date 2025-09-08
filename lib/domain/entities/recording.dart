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
