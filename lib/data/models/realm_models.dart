import 'package:realm/realm.dart';
import '../../domain/entities/recording.dart';

part 'realm_models.realm.dart';

@RealmModel()
class _RecordingRealm {
  @PrimaryKey()
  late String id;
  
  late String title;
  late String audioPath;
  late int durationMs;
  late DateTime createdAt;
  DateTime? updatedAt;
  late String status;
  late double progress;
  String? transcript;
  String? summary;
  late bool isSynced;
  late String transcriptionStatus;
  DateTime? transcriptionCompletedAt;
  String? transcriptionError;
}

// Extension methods for the generated RecordingRealm class
extension RecordingRealmExtension on RecordingRealm {
  Duration get duration => Duration(milliseconds: durationMs);
  
  RecordingStatus get recordingStatus => RecordingStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => RecordingStatus.completed,
  );
  
  TranscriptionStatus get transcriptionStatusEnum => TranscriptionStatus.values.firstWhere(
    (e) => e.name == transcriptionStatus,
    orElse: () => TranscriptionStatus.notStarted,
  );
  
  set recordingStatus(RecordingStatus value) {
    status = value.name;
  }
  
  Recording toEntity() {
    return Recording(
      id: id,
      title: title,
      audioPath: audioPath,
      duration: duration,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: recordingStatus,
      progress: progress,
      transcript: transcript,
      summary: summary,
      isSynced: isSynced,
      transcriptionStatus: transcriptionStatusEnum,
      transcriptionCompletedAt: transcriptionCompletedAt,
      transcriptionError: transcriptionError,
    );
  }
  
  static RecordingRealm fromEntity(Recording recording) {
    return RecordingRealm(
      recording.id,
      recording.title,
      recording.audioPath,
      recording.duration.inMilliseconds,
      recording.createdAt,
      recording.status.name,
      recording.progress,
      recording.isSynced,
      recording.transcriptionStatus.name,
      updatedAt: recording.updatedAt,
      transcript: recording.transcript,
      summary: recording.summary,
      transcriptionCompletedAt: recording.transcriptionCompletedAt,
      transcriptionError: recording.transcriptionError,
    );
  }
}
