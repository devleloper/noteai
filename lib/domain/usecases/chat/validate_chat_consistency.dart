import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/sync/chat_consistency_service.dart';

class ValidateChatConsistency {
  final ChatConsistencyService _chatConsistencyService;

  ValidateChatConsistency(this._chatConsistencyService);

  /// Validate consistency of chat messages for a session
  Future<Either<Failure, bool>> call(String sessionId) async {
    try {
      final isValid = await _chatConsistencyService.validateMessageConsistency(sessionId);
      return Right(isValid);
    } catch (e) {
      return Left(DatabaseFailure('Failed to validate chat consistency: $e'));
    }
  }
}
