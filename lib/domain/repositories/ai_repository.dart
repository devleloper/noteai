import 'package:dartz/dartz.dart';
import '../entities/transcript.dart';
import '../entities/summary.dart';
import '../entities/chat_message.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class AIRepository {
  Future<Either<Failure, Transcript>> transcribeAudio(String audioPath);
  Future<Either<Failure, Summary>> generateSummary(String transcript, UserPreferences preferences);
  Future<Either<Failure, String>> askQuestion(String recordingId, String question, List<ChatMessage> context);
  Future<Either<Failure, void>> saveChatMessage(ChatMessage message);
  Future<Either<Failure, List<ChatMessage>>> getChatMessages(String recordingId);
}
