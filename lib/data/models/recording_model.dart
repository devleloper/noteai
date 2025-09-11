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
    required super.transcriptionStatus,
    super.transcriptionCompletedAt,
    super.transcriptionError,
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
      transcriptionStatus: TranscriptionStatus.values.firstWhere(
        (e) => e.name == json['transcriptionStatus'],
        orElse: () => TranscriptionStatus.notStarted,
      ),
      transcriptionCompletedAt: json['transcriptionCompletedAt'] != null
          ? DateTime.parse(json['transcriptionCompletedAt'] as String)
          : null,
      transcriptionError: json['transcriptionError'] as String?,
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
      'transcriptionStatus': transcriptionStatus.name,
      'transcriptionCompletedAt': transcriptionCompletedAt?.toIso8601String(),
      'transcriptionError': transcriptionError,
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
      transcriptionStatus: recording.transcriptionStatus,
      transcriptionCompletedAt: recording.transcriptionCompletedAt,
      transcriptionError: recording.transcriptionError,
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
      transcriptionStatus: transcriptionStatus,
      transcriptionCompletedAt: transcriptionCompletedAt,
      transcriptionError: transcriptionError,
    );
  }
  
  Map<String, dynamic> toMap() {
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
      'transcriptionStatus': transcriptionStatus.name,
      'transcriptionCompletedAt': transcriptionCompletedAt?.toIso8601String(),
      'transcriptionError': transcriptionError,
    };
  }
  
  factory RecordingModel.fromMap(Map<String, dynamic> map, String id) {
    return RecordingModel(
      id: id,
      title: map['title'] as String,
      audioPath: map['audioPath'] as String,
      duration: Duration(milliseconds: map['duration'] as int),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String) 
          : null,
      status: RecordingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RecordingStatus.completed,
      ),
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      transcript: map['transcript'] as String?,
      summary: map['summary'] as String?,
      isSynced: map['isSynced'] as bool? ?? false,
      transcriptionStatus: TranscriptionStatus.values.firstWhere(
        (e) => e.name == map['transcriptionStatus'],
        orElse: () => TranscriptionStatus.notStarted,
      ),
      transcriptionCompletedAt: map['transcriptionCompletedAt'] != null
          ? DateTime.parse(map['transcriptionCompletedAt'] as String)
          : null,
      transcriptionError: map['transcriptionError'] as String?,
    );
  }
}
