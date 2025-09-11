import 'package:dartz/dartz.dart';
import '../../domain/entities/transcript.dart';
import '../../domain/entities/summary.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/openai_datasource.dart';
import '../datasources/local/realm_datasource.dart';

class AIRepositoryImpl implements AIRepository {
  final OpenAIDataSource openAIDataSource;
  final RealmDataSource localDataSource;
  
  AIRepositoryImpl({
    required this.openAIDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, Transcript>> transcribeAudio(String audioPath) async {
    try {
      final transcriptText = await openAIDataSource.transcribeAudio(audioPath);
      final transcript = Transcript(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recordingId: 'mock_recording_id',
        content: transcriptText,
        createdAt: DateTime.now(),
        isSynced: false,
      );
      return Right(transcript);
    } catch (e) {
      return Left(AITranscriptionFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Summary>> generateSummary(String transcript, UserPreferences preferences) async {
    try {
      final summaryText = await openAIDataSource.generateSummary(transcript);
      final summary = Summary(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recordingId: 'mock_recording_id',
        content: summaryText,
        keyPoints: ['Key point 1', 'Key point 2'],
        actionItems: ['Action item 1', 'Action item 2'],
        createdAt: DateTime.now(),
        isSynced: false,
      );
      return Right(summary);
    } catch (e) {
      return Left(AISummaryFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, String>> askQuestion(String recordingId, String question, List<ChatMessage> context) async {
    try {
      // Build context from chat messages
      final contextText = context.map((msg) => '${msg.type.name}: ${msg.content}').join('\n');
      final answer = await openAIDataSource.askQuestion(question, contextText);
      return Right(answer);
    } catch (e) {
      return Left(AIChatFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> saveChatMessage(ChatMessage message) async {
    try {
      // TODO: Save chat message to local storage
      throw UnimplementedError();
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ChatMessage>>> getChatMessages(String recordingId) async {
    try {
      // TODO: Retrieve chat messages from local storage
      throw UnimplementedError();
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
