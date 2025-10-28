import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/chat_message.dart';
import '../../repositories/chat_repository.dart';

class GetChatHistory {
  final ChatRepository repository;

  GetChatHistory(this.repository);

  Future<Either<Failure, List<ChatMessage>>> call(String sessionId) async {
    return await repository.getMessages(sessionId);
  }
}
