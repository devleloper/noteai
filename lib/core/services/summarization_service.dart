import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/summarization_state.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/summarization_state_repository.dart';
import '../../data/datasources/remote/ai_chat_service.dart';
import '../../core/network/network_info.dart';
import 'sync/offline_queue.dart';
import '../../data/models/sync/sync_models.dart';

class SummarizationService {
  final ChatRepository _chatRepository;
  final AIChatService _aiService;
  final NetworkInfo _networkInfo;
  final OfflineQueue _offlineQueue;
  final SummarizationStateRepository _stateRepository;
  final Map<String, StreamController<SummarizationState>> _streamControllers = {};
  final Map<String, SummarizationState> _stateCache = {};
  
  // Retry configuration
  static const int _maxRetries = 5;
  static const Duration _baseRetryDelay = Duration(seconds: 2);
  static const Duration _maxRetryDelay = Duration(minutes: 10);

  SummarizationService({
    required ChatRepository chatRepository,
    required AIChatService aiService,
    required NetworkInfo networkInfo,
    required OfflineQueue offlineQueue,
    required SummarizationStateRepository stateRepository,
  }) : _chatRepository = chatRepository,
       _aiService = aiService,
       _networkInfo = networkInfo,
       _offlineQueue = offlineQueue,
       _stateRepository = stateRepository;

  /// Get summarization state for a recording
  Future<Either<Failure, SummarizationState?>> getSummarizationState(String recordingId) async {
    try {
      // Check cache first
      if (_stateCache.containsKey(recordingId)) {
        return Right(_stateCache[recordingId]);
      }

      // Check if session already has a summary
      final sessionResult = await _chatRepository.getSessionByRecordingId(recordingId);
      if (sessionResult.isRight()) {
        final session = sessionResult.getOrElse(() => throw Exception('Failed to get session'));
        if (session.hasSummary && session.summary != null && session.summary!.isNotEmpty) {
          final completedState = SummarizationState(
            recordingId: recordingId,
            status: SummarizationStatus.completed,
            retryAttempts: 0,
            generatedSummary: session.summary,
            createdAt: session.createdAt,
            updatedAt: session.updatedAt,
          );
          _stateCache[recordingId] = completedState;
          // Persist the completed state
          await _stateRepository.saveSummarizationState(completedState);
          return Right(completedState);
        }
      }

      // Check persisted state from database
      final persistedStateResult = await _stateRepository.getSummarizationState(recordingId);
      if (persistedStateResult.isRight()) {
        final persistedState = persistedStateResult.getOrElse(() => throw Exception('Failed to get persisted state'));
        if (persistedState != null) {
          _stateCache[recordingId] = persistedState;
          return Right(persistedState);
        }
      }

      // Check for pending operations in offline queue
      final pendingOps = _offlineQueue.getPendingOperationsByType('summarization');
      try {
        final pendingOp = pendingOps.firstWhere(
          (op) => op.data['recordingId'] == recordingId,
        );
        
        final pendingState = SummarizationState(
          recordingId: recordingId,
          status: SummarizationStatus.pending,
          retryAttempts: pendingOp.retryCount,
          error: pendingOp.error,
          lastAttempt: pendingOp.timestamp,
          createdAt: pendingOp.timestamp,
          updatedAt: DateTime.now(),
        );
        _stateCache[recordingId] = pendingState;
        // Persist the pending state
        await _stateRepository.saveSummarizationState(pendingState);
        return Right(pendingState);
      } catch (e) {
        // No pending operation found, continue to default state
      }

      // Return default pending state
      final state = SummarizationState(
        recordingId: recordingId,
        status: SummarizationStatus.pending,
        retryAttempts: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _stateCache[recordingId] = state;
      // Persist the default state
      await _stateRepository.saveSummarizationState(state);
      return Right(state);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get summarization state: $e'));
    }
  }

  /// Generate summary on demand with retry logic
  Future<Either<Failure, SummarizationState>> generateSummaryOnDemand({
    required String recordingId,
    required String transcript,
    required String model,
    required String language,
  }) async {
    try {
      // Check if already completed
      final existingState = await getSummarizationState(recordingId);
      if (existingState.isRight()) {
        final state = existingState.getOrElse(() => throw Exception('Failed to get state'));
        if (state != null && state.isCompleted) {
          return Right(state);
        }
      }

      // Check network connectivity
      final isConnected = await _networkInfo.isConnected;
      
      if (!isConnected) {
        // Add to offline queue for later processing
        await _addToOfflineQueue(
          recordingId: recordingId,
          transcript: transcript,
          model: model,
          language: language,
        );
        
        final pendingState = SummarizationState(
          recordingId: recordingId,
          status: SummarizationStatus.pending,
          retryAttempts: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _stateCache[recordingId] = pendingState;
        _emitState(recordingId, pendingState);
        return Right(pendingState);
      }

             // Create initial state
             final initialState = SummarizationState(
               recordingId: recordingId,
               status: SummarizationStatus.generating,
               retryAttempts: 0,
               createdAt: DateTime.now(),
               updatedAt: DateTime.now(),
             );
             _stateCache[recordingId] = initialState;
             _emitState(recordingId, initialState);
             // Persist the generating state
             await _stateRepository.saveSummarizationState(initialState);

      // Generate summary with enhanced retry logic
      final result = await _generateSummaryWithRetry(
        recordingId: recordingId,
        transcript: transcript,
        model: model,
        language: language,
        maxRetries: _maxRetries,
      );

             return result.fold(
               (failure) {
                 final failedState = initialState.copyWith(
                   status: SummarizationStatus.failed,
                   error: failure.message,
                   updatedAt: DateTime.now(),
                 );
                 _stateCache[recordingId] = failedState;
                 _emitState(recordingId, failedState);
                 // Persist the failed state
                 _stateRepository.saveSummarizationState(failedState);
                 
                 // Add to offline queue for retry
                 _addToOfflineQueue(
                   recordingId: recordingId,
                   transcript: transcript,
                   model: model,
                   language: language,
                 );
                 
                 return Left(failure);
               },
               (summary) {
                 final completedState = initialState.copyWith(
                   status: SummarizationStatus.completed,
                   generatedSummary: summary,
                   updatedAt: DateTime.now(),
                 );
                 _stateCache[recordingId] = completedState;
                 _emitState(recordingId, completedState);
                 // Persist the completed state
                 _stateRepository.saveSummarizationState(completedState);
                 return Right(completedState);
               },
             );
    } catch (e) {
      final errorState = SummarizationState(
        recordingId: recordingId,
        status: SummarizationStatus.failed,
        retryAttempts: 0,
        error: e.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _stateCache[recordingId] = errorState;
      _emitState(recordingId, errorState);
      // Persist the error state
      _stateRepository.saveSummarizationState(errorState);
      return Left(DatabaseFailure('Failed to generate summary: $e'));
    }
  }

  /// Generate summary with exponential backoff retry
  Future<Either<Failure, String>> _generateSummaryWithRetry({
    required String recordingId,
    required String transcript,
    required String model,
    required String language,
    required int maxRetries,
  }) async {
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        // Check network connectivity before each attempt
        final isConnected = await _networkInfo.isConnected;
        if (!isConnected) {
          return Left(NetworkFailure('No network connection available'));
        }

               // Update retry count in state
               if (retryCount > 0) {
                 final retryState = SummarizationState(
                   recordingId: recordingId,
                   status: SummarizationStatus.generating,
                   retryAttempts: retryCount,
                   lastAttempt: DateTime.now(),
                   createdAt: DateTime.now(),
                   updatedAt: DateTime.now(),
                 );
                 _stateCache[recordingId] = retryState;
                 _emitState(recordingId, retryState);
                 // Persist the retry state
                 await _stateRepository.saveSummarizationState(retryState);
               }

        // Attempt to generate summary
        final summary = await _aiService.generateSummary(
          transcript: transcript,
          model: model,
          language: language,
        );

        // Update session with summary
        final updateResult = await _chatRepository.generateSummary(
          GenerateSummaryParams(
            recordingId: recordingId,
            transcript: transcript,
            model: model,
            language: language,
          ),
        );

        return updateResult.fold(
          (failure) => Left(failure),
          (_) => Right(summary),
        );
      } catch (e) {
        retryCount++;
        
        if (retryCount > maxRetries) {
          return Left(AIFailure('Failed to generate summary after $maxRetries retries: $e'));
        }

        // Calculate exponential backoff delay with jitter
        final baseDelayMs = _baseRetryDelay.inMilliseconds;
        final exponentialDelayMs = baseDelayMs * (1 << (retryCount - 1));
        final jitterMs = (exponentialDelayMs * 0.1 * (0.5 - (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).round();
        final delayMs = (exponentialDelayMs + jitterMs).clamp(
          _baseRetryDelay.inMilliseconds,
          _maxRetryDelay.inMilliseconds,
        );

        // Wait before retrying
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    return Left(AIFailure('Unexpected error in retry logic'));
  }

  /// Stream summarization state changes
  Stream<SummarizationState> watchSummarizationState(String recordingId) {
    if (!_streamControllers.containsKey(recordingId)) {
      _streamControllers[recordingId] = StreamController<SummarizationState>.broadcast();
    }
    return _streamControllers[recordingId]!.stream;
  }

  /// Emit state change
  void _emitState(String recordingId, SummarizationState state) {
    if (_streamControllers.containsKey(recordingId)) {
      _streamControllers[recordingId]!.add(state);
    }
  }

  /// Add summarization task to offline queue
  Future<void> _addToOfflineQueue({
    required String recordingId,
    required String transcript,
    required String model,
    required String language,
  }) async {
    final operation = SyncOperation(
      id: 'summarization_${recordingId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'summarization',
      entityId: recordingId,
      data: {
        'recordingId': recordingId,
        'transcript': transcript,
        'model': model,
        'language': language,
        'createdAt': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
      retryCount: 0,
    );

    await _offlineQueue.addOperation(operation);
  }

  /// Process pending summarization operations from offline queue
  Future<void> processPendingSummarizations() async {
    try {
      final pendingOps = _offlineQueue.getPendingOperationsByType('summarization');
      
      for (final operation in pendingOps) {
        try {
          await _processSummarizationOperation(operation);
          await _offlineQueue.removeOperation(operation.id);
        } catch (e) {
          print('Failed to process summarization operation ${operation.id}: $e');
          // Operation will be retried by offline queue
        }
      }
    } catch (e) {
      print('Error processing pending summarizations: $e');
    }
  }

  /// Process a single summarization operation
  Future<void> _processSummarizationOperation(SyncOperation operation) async {
    final recordingId = operation.data['recordingId'] as String;
    final transcript = operation.data['transcript'] as String;
    final model = operation.data['model'] as String;
    final language = operation.data['language'] as String;

    // Check if already completed
    final existingState = await getSummarizationState(recordingId);
    if (existingState.isRight()) {
      final state = existingState.getOrElse(() => throw Exception('Failed to get state'));
      if (state != null && state.isCompleted) {
        return; // Already completed, skip
      }
    }

    // Attempt to generate summary
    final result = await generateSummaryOnDemand(
      recordingId: recordingId,
      transcript: transcript,
      model: model,
      language: language,
    );

    result.fold(
      (failure) => throw Exception('Summarization failed: ${failure.message}'),
      (state) {
        if (state.isFailed) {
          throw Exception('Summarization failed: ${state.error}');
        }
      },
    );
  }

  /// Retry failed summarizations
  Future<void> retryFailedSummarizations() async {
    try {
      final failedOps = _offlineQueue.getPendingOperationsByType('summarization')
          .where((op) => op.retryCount > 0)
          .toList();

      for (final operation in failedOps) {
        if (_offlineQueue.shouldRetryOperation(operation)) {
          try {
            await _processSummarizationOperation(operation);
            await _offlineQueue.removeOperation(operation.id);
          } catch (e) {
            print('Retry failed for operation ${operation.id}: $e');
          }
        }
      }
    } catch (e) {
      print('Error retrying failed summarizations: $e');
    }
  }

  /// Get summarization statistics
  Map<String, dynamic> getSummarizationStats() {
    final stats = <String, int>{
      'totalStates': _stateCache.length,
      'completed': 0,
      'pending': 0,
      'generating': 0,
      'failed': 0,
    };

    for (final state in _stateCache.values) {
      switch (state.status) {
        case SummarizationStatus.completed:
          stats['completed'] = (stats['completed'] ?? 0) + 1;
          break;
        case SummarizationStatus.pending:
          stats['pending'] = (stats['pending'] ?? 0) + 1;
          break;
        case SummarizationStatus.generating:
          stats['generating'] = (stats['generating'] ?? 0) + 1;
          break;
        case SummarizationStatus.failed:
          stats['failed'] = (stats['failed'] ?? 0) + 1;
          break;
      }
    }

    final queueStats = _offlineQueue.getQueueStats();
    stats.addAll({
      'pendingOperations': queueStats['totalOperations'] ?? 0,
      'retryOperations': queueStats['retryOperations'] ?? 0,
    });

    return stats;
  }

  /// Clear cache for a specific recording
  void clearCache(String recordingId) {
    _stateCache.remove(recordingId);
    if (_streamControllers.containsKey(recordingId)) {
      _streamControllers[recordingId]!.close();
      _streamControllers.remove(recordingId);
    }
  }

  /// Clear all cache
  void clearAllCache() {
    _stateCache.clear();
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }

  /// Resume interrupted summarizations on app startup
  Future<void> resumeInterruptedSummarizations() async {
    try {
      // Get all pending and generating states
      final pendingResult = await _stateRepository.getStatesByStatus(SummarizationStatus.pending);
      final generatingResult = await _stateRepository.getStatesByStatus(SummarizationStatus.generating);
      
      final pendingStates = pendingResult.fold((failure) => <SummarizationState>[], (states) => states);
      final generatingStates = generatingResult.fold((failure) => <SummarizationState>[], (states) => states);
      
      // Reset generating states to pending (they were interrupted)
      for (final state in generatingStates) {
        final resetState = state.copyWith(
          status: SummarizationStatus.pending,
          updatedAt: DateTime.now(),
        );
        await _stateRepository.saveSummarizationState(resetState);
        _stateCache[state.recordingId] = resetState;
      }
      
      // Process all pending states
      final allPendingStates = [...pendingStates, ...generatingStates.map((s) => s.copyWith(status: SummarizationStatus.pending))];
      
      for (final state in allPendingStates) {
        // Add to offline queue for processing
        await _addToOfflineQueue(
          recordingId: state.recordingId,
          transcript: '', // Will be fetched when processing
          model: 'gpt-4', // Default model
          language: 'en', // Default language
        );
      }
      
      print('SummarizationService: Resumed ${allPendingStates.length} interrupted summarizations');
    } catch (e) {
      print('SummarizationService: Failed to resume interrupted summarizations: $e');
    }
  }

  /// Clear all summarization states
  Future<void> clearAllSummarizationStates() async {
    try {
      await _stateRepository.clearAllStates();
      _stateCache.clear();
      print('SummarizationService: Cleared all summarization states');
    } catch (e) {
      print('SummarizationService: Failed to clear summarization states: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    clearAllCache();
  }
}
