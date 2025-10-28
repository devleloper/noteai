import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/summarization_state.dart';

abstract class SummarizationStateRepository {
  /// Get summarization state for a recording
  Future<Either<Failure, SummarizationState?>> getSummarizationState(String recordingId);
  
  /// Save or update summarization state
  Future<Either<Failure, void>> saveSummarizationState(SummarizationState state);
  
  /// Delete summarization state
  Future<Either<Failure, void>> deleteSummarizationState(String recordingId);
  
  /// Get all pending summarization states
  Future<Either<Failure, List<SummarizationState>>> getPendingStates();
  
  /// Get all failed summarization states
  Future<Either<Failure, List<SummarizationState>>> getFailedStates();
  
  /// Get all completed summarization states
  Future<Either<Failure, List<SummarizationState>>> getCompletedStates();
  
  /// Get summarization states by status
  Future<Either<Failure, List<SummarizationState>>> getStatesByStatus(SummarizationStatus status);
  
  /// Update summarization state status
  Future<Either<Failure, void>> updateStatus(String recordingId, SummarizationStatus status);
  
  /// Increment retry attempts
  Future<Either<Failure, void>> incrementRetryAttempts(String recordingId);
  
  /// Clear all summarization states
  Future<Either<Failure, void>> clearAllStates();
  
  /// Get summarization statistics
  Future<Either<Failure, Map<String, int>>> getStatistics();
}
