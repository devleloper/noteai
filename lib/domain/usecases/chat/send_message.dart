import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/chat_message.dart';
import '../../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Either<Failure, ChatMessage>> call(SendMessageParams params) async {
    return await repository.sendMessage(params);
  }
}
