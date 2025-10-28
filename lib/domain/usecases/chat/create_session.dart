import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/chat_session.dart';
import '../../repositories/chat_repository.dart';

class CreateSession {
  final ChatRepository repository;

  CreateSession(this.repository);

  Future<Either<Failure, ChatSession>> call(String recordingId) async {
    return await repository.createSession(recordingId);
  }
}
