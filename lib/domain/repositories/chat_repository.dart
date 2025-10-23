import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/chat_session.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  // Session management
  Future<Either<Failure, ChatSession>> createSession(String recordingId);
  Future<Either<Failure, ChatSession>> getSession(String sessionId);
  Future<Either<Failure, ChatSession>> getSessionByRecordingId(String recordingId);
  Future<Either<Failure, void>> updateSession(ChatSession session);
  Future<Either<Failure, void>> deleteSession(String sessionId);

  // Message management
  Future<Either<Failure, List<ChatMessage>>> getMessages(String sessionId);
  Future<Either<Failure, List<ChatMessage>>> getMessagesLazy({
    required String sessionId,
    int limit = 20,
    int offset = 0,
  });
  Future<Either<Failure, ChatMessage>> sendMessage(SendMessageParams params);
  Future<Either<Failure, ChatMessage>> regenerateMessage(RegenerateMessageParams params);
  Future<Either<Failure, void>> deleteMessage(String messageId);

  // Summary generation
  Future<Either<Failure, String>> generateSummary(GenerateSummaryParams params);
  Future<Either<Failure, void>> updateSummary(String sessionId, String summary);

  // Model management
  Future<Either<Failure, String>> getDefaultModel();
  Future<Either<Failure, void>> setDefaultModel(String model);
  Future<Either<Failure, List<String>>> getAvailableModels();
}

class SendMessageParams {
  final String sessionId;
  final String content;
  final String? model;
  final String? parentMessageId;

  const SendMessageParams({
    required this.sessionId,
    required this.content,
    this.model,
    this.parentMessageId,
  });
}

class RegenerateMessageParams {
  final String messageId;
  final String sessionId;
  final String? model;

  const RegenerateMessageParams({
    required this.messageId,
    required this.sessionId,
    this.model,
  });
}

class GenerateSummaryParams {
  final String recordingId;
  final String transcript;
  final String model;
  final String language;

  const GenerateSummaryParams({
    required this.recordingId,
    required this.transcript,
    required this.model,
    required this.language,
  });
}
