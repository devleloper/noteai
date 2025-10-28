import 'package:realm/realm.dart';
import '../../domain/entities/recording.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/summarization_state.dart';

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

// Chat Message Realm Model
@RealmModel()
class _ChatMessageRealm {
  @PrimaryKey()
  late String id;
  late String sessionId;
  late String type; // MessageType enum as string
  late String content;
  String? model;
  late DateTime timestamp;
  String? parentMessageId;
  String? metadata; // JSON string for metadata
}

// Chat Session Realm Model
@RealmModel()
class _ChatSessionRealm {
  @PrimaryKey()
  late String id;
  late String recordingId;
  String? summary;
  late String defaultModel;
  late DateTime createdAt;
  late DateTime updatedAt;
}

// Summarization State Realm Model
@RealmModel()
class _SummarizationStateRealm {
  @PrimaryKey()
  late String recordingId;
  late String status; // SummarizationStatus enum as string
  late int retryAttempts;
  String? error;
  DateTime? lastAttempt;
  String? generatedSummary;
  late DateTime createdAt;
  late DateTime updatedAt;
}

// Extension methods for SummarizationStateRealm
extension SummarizationStateRealmExtension on SummarizationStateRealm {
  SummarizationStatus get summarizationStatus => SummarizationStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => SummarizationStatus.pending,
  );
  
  set summarizationStatus(SummarizationStatus value) {
    status = value.name;
  }
  
  SummarizationState toEntity() {
    return SummarizationState(
      recordingId: recordingId,
      status: summarizationStatus,
      retryAttempts: retryAttempts,
      error: error,
      lastAttempt: lastAttempt,
      generatedSummary: generatedSummary,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  static SummarizationStateRealm fromEntity(SummarizationState state) {
    return SummarizationStateRealm(
      state.recordingId,
      state.status.name,
      state.retryAttempts,
      state.createdAt,
      state.updatedAt,
      error: state.error,
      lastAttempt: state.lastAttempt,
      generatedSummary: state.generatedSummary,
    );
  }
}
