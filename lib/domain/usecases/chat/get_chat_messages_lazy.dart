import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/chat_message.dart';
import '../../repositories/chat_repository.dart';

class GetChatMessagesLazy {
  final ChatRepository repository;

  GetChatMessagesLazy(this.repository);

  /// Loads chat messages with pagination support
  /// [sessionId] - The chat session ID
  /// [limit] - Maximum number of messages to load (default: 20)
  /// [offset] - Number of messages to skip (default: 0)
  Future<Either<Failure, List<ChatMessage>>> call({
    required String sessionId,
    int limit = 20,
    int offset = 0,
  }) async {
    return await repository.getMessagesLazy(
      sessionId: sessionId,
      limit: limit,
      offset: offset,
    );
  }
}
