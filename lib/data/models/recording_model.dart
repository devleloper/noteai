import '../../domain/entities/recording.dart';

class RecordingModel extends Recording {
  const RecordingModel({
    required super.id,
    required super.title,
    required super.audioPath,
    required super.duration,
    required super.createdAt,
    super.updatedAt,
    required super.status,
    required super.progress,
    super.transcript,
    super.summary,
    required super.isSynced,
  });
  
  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    return RecordingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      audioPath: json['audioPath'] as String,
      duration: Duration(milliseconds: json['duration'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      status: RecordingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RecordingStatus.completed,
      ),
      progress: (json['progress'] as num).toDouble(),
      transcript: json['transcript'] as String?,
      summary: json['summary'] as String?,
      isSynced: json['isSynced'] as bool,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'audioPath': audioPath,
      'duration': duration.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.name,
      'progress': progress,
      'transcript': transcript,
      'summary': summary,
      'isSynced': isSynced,
    };
  }
  
  factory RecordingModel.fromEntity(Recording recording) {
    return RecordingModel(
      id: recording.id,
      title: recording.title,
      audioPath: recording.audioPath,
      duration: recording.duration,
      createdAt: recording.createdAt,
      updatedAt: recording.updatedAt,
      status: recording.status,
      progress: recording.progress,
      transcript: recording.transcript,
      summary: recording.summary,
      isSynced: recording.isSynced,
    );
  }
  
  Recording toEntity() {
    return Recording(
      id: id,
      title: title,
      audioPath: audioPath,
      duration: duration,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status,
      progress: progress,
      transcript: transcript,
      summary: summary,
      isSynced: isSynced,
    );
  }
}
