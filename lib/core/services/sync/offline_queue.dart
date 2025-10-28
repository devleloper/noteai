import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/sync/sync_models.dart';

/// Manages offline operations queue for cross-device synchronization
class OfflineQueue {
  static final OfflineQueue _instance = OfflineQueue._internal();
  factory OfflineQueue() => _instance;
  OfflineQueue._internal();

  SharedPreferences? _prefs;
  final List<SyncOperation> _pendingOperations = [];
  
  static const String _queueKey = 'offline_queue';
  static const int _maxRetryCount = 3;
  static const Duration _retryDelay = Duration(minutes: 5);

  /// Initialize the offline queue
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPendingOperations();
    print('OfflineQueue: Initialized with ${_pendingOperations.length} pending operations');
  }

  /// Add operation to offline queue
  Future<void> addOperation(SyncOperation operation) async {
    _pendingOperations.add(operation);
    await _savePendingOperations();
    print('OfflineQueue: Added operation ${operation.id} to queue');
  }

  /// Add transcript sync operation
  Future<void> addTranscriptSync({
    required String transcriptId,
    required String content,
    required String recordingId,
    required DateTime updatedAt,
  }) async {
    final operation = SyncOperation(
      id: 'transcript_${transcriptId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'transcript_sync',
      entityId: transcriptId,
      data: {
        'content': content,
        'recordingId': recordingId,
        'updatedAt': updatedAt.toIso8601String(),
      },
      timestamp: DateTime.now(),
      retryCount: 0,
    );

    await addOperation(operation);
  }

  /// Add chat message sync operation
  Future<void> addChatMessageSync({
    required String messageId,
    required String content,
    required String recordingId,
    required String role,
    required DateTime timestamp,
    required String? model,
  }) async {
    final operation = SyncOperation(
      id: 'chat_${messageId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'chat_message_sync',
      entityId: messageId,
      data: {
        'content': content,
        'recordingId': recordingId,
        'role': role,
        'timestamp': timestamp.toIso8601String(),
        'model': model,
      },
      timestamp: DateTime.now(),
      retryCount: 0,
    );

    await addOperation(operation);
  }

  /// Add audio metadata sync operation
  Future<void> addAudioMetadataSync(AudioMetadata metadata) async {
    final operation = SyncOperation(
      id: 'audio_${metadata.recordingId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'audio_metadata_sync',
      entityId: metadata.recordingId,
      data: metadata.toJson(),
      timestamp: DateTime.now(),
      retryCount: 0,
    );

    await addOperation(operation);
  }

  /// Add delete operation
  Future<void> addDeleteOperation({
    required String entityId,
    required String type,
  }) async {
    final operation = SyncOperation(
      id: 'delete_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
      type: 'delete_$type',
      entityId: entityId,
      data: {
        'deletedAt': DateTime.now().toIso8601String(),
      },
      timestamp: DateTime.now(),
      retryCount: 0,
    );

    await addOperation(operation);
  }

  /// Process all pending operations
  Future<void> processPendingOperations() async {
    if (_pendingOperations.isEmpty) {
      print('OfflineQueue: No pending operations to process');
      return;
    }

    print('OfflineQueue: Processing ${_pendingOperations.length} pending operations');

    final operationsToRetry = <SyncOperation>[];
    final operationsToRemove = <String>[];

    for (final operation in _pendingOperations) {
      try {
        await _processOperation(operation);
        operationsToRemove.add(operation.id);
        print('OfflineQueue: Successfully processed operation ${operation.id}');
      } catch (e) {
        print('OfflineQueue: Failed to process operation ${operation.id}: $e');
        
        if (operation.retryCount < _maxRetryCount) {
          // Retry operation
          final retryOperation = operation.copyWith(
            retryCount: operation.retryCount + 1,
            error: e.toString(),
          );
          operationsToRetry.add(retryOperation);
          operationsToRemove.add(operation.id);
        } else {
          // Max retries reached, remove from queue
          operationsToRemove.add(operation.id);
          print('OfflineQueue: Max retries reached for operation ${operation.id}, removing from queue');
        }
      }
    }

    // Remove processed operations
    for (final operationId in operationsToRemove) {
      _pendingOperations.removeWhere((op) => op.id == operationId);
    }

    // Add retry operations
    _pendingOperations.addAll(operationsToRetry);

    await _savePendingOperations();
    print('OfflineQueue: Queue processing complete. ${_pendingOperations.length} operations remaining');
  }

  /// Get pending operations count
  int get pendingOperationsCount => _pendingOperations.length;

  /// Get pending operations by type
  List<SyncOperation> getPendingOperationsByType(String type) {
    return _pendingOperations.where((op) => op.type == type).toList();
  }

  /// Get all pending operations
  List<SyncOperation> get allPendingOperations => List.unmodifiable(_pendingOperations);

  /// Clear all pending operations
  Future<void> clearAllOperations() async {
    _pendingOperations.clear();
    await _savePendingOperations();
    print('OfflineQueue: All operations cleared');
  }

  /// Remove specific operation
  Future<void> removeOperation(String operationId) async {
    _pendingOperations.removeWhere((op) => op.id == operationId);
    await _savePendingOperations();
    print('OfflineQueue: Operation $operationId removed');
  }

  /// Get queue statistics
  Map<String, dynamic> getQueueStats() {
    final stats = <String, int>{};
    
    for (final operation in _pendingOperations) {
      final type = operation.type;
      stats[type] = (stats[type] ?? 0) + 1;
    }

    return {
      'totalOperations': _pendingOperations.length,
      'operationsByType': stats,
      'retryOperations': _pendingOperations.where((op) => op.retryCount > 0).length,
    };
  }

  /// Check if operation should be retried
  bool shouldRetryOperation(SyncOperation operation) {
    if (operation.retryCount >= _maxRetryCount) return false;
    
    final now = DateTime.now();
    final lastRetry = operation.timestamp.add(Duration(minutes: operation.retryCount * 5));
    
    return now.isAfter(lastRetry);
  }

  // Private methods

  Future<void> _loadPendingOperations() async {
    if (_prefs == null) return;

    final jsonString = _prefs!.getString(_queueKey);
    if (jsonString == null) return;

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _pendingOperations.clear();
      
      for (final json in jsonList) {
        final operation = SyncOperation(
          id: json['id'] as String,
          type: json['type'] as String,
          entityId: json['entityId'] as String,
          data: Map<String, dynamic>.from(json['data'] as Map),
          timestamp: DateTime.parse(json['timestamp'] as String),
          retryCount: json['retryCount'] as int,
          error: json['error'] as String?,
        );
        _pendingOperations.add(operation);
      }
    } catch (e) {
      print('OfflineQueue: Error loading pending operations: $e');
      _pendingOperations.clear();
    }
  }

  Future<void> _savePendingOperations() async {
    if (_prefs == null) return;

    try {
      final jsonList = _pendingOperations.map((op) => {
        'id': op.id,
        'type': op.type,
        'entityId': op.entityId,
        'data': op.data,
        'timestamp': op.timestamp.toIso8601String(),
        'retryCount': op.retryCount,
        'error': op.error,
      }).toList();

      final jsonString = jsonEncode(jsonList);
      await _prefs!.setString(_queueKey, jsonString);
    } catch (e) {
      print('OfflineQueue: Error saving pending operations: $e');
    }
  }

  Future<void> _processOperation(SyncOperation operation) async {
    switch (operation.type) {
      case 'transcript_sync':
        await _processTranscriptSync(operation);
        break;
      case 'chat_message_sync':
        await _processChatMessageSync(operation);
        break;
      case 'audio_metadata_sync':
        await _processAudioMetadataSync(operation);
        break;
      case 'summarization':
        await _processSummarization(operation);
        break;
      case 'delete_transcript':
        await _processDeleteTranscript(operation);
        break;
      case 'delete_chat':
        await _processDeleteChat(operation);
        break;
      case 'delete_audio_metadata':
        await _processDeleteAudioMetadata(operation);
        break;
      default:
        throw Exception('Unknown operation type: ${operation.type}');
    }
  }

  Future<void> _processTranscriptSync(SyncOperation operation) async {
    // TODO: Implement actual transcript sync
    print('OfflineQueue: Processing transcript sync for ${operation.entityId}');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate processing
  }

  Future<void> _processChatMessageSync(SyncOperation operation) async {
    // TODO: Implement actual chat message sync
    print('OfflineQueue: Processing chat message sync for ${operation.entityId}');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate processing
  }

  Future<void> _processAudioMetadataSync(SyncOperation operation) async {
    // TODO: Implement actual audio metadata sync
    print('OfflineQueue: Processing audio metadata sync for ${operation.entityId}');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate processing
  }

  Future<void> _processSummarization(SyncOperation operation) async {
    // TODO: Implement actual summarization processing
    // This will be handled by SummarizationService.processPendingSummarizations()
    print('OfflineQueue: Processing summarization for ${operation.entityId}');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate processing
  }

  Future<void> _processDeleteTranscript(SyncOperation operation) async {
    // TODO: Implement actual transcript deletion
    print('OfflineQueue: Processing transcript deletion for ${operation.entityId}');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate processing
  }

  Future<void> _processDeleteChat(SyncOperation operation) async {
    // TODO: Implement actual chat deletion
    print('OfflineQueue: Processing chat deletion for ${operation.entityId}');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate processing
  }

  Future<void> _processDeleteAudioMetadata(SyncOperation operation) async {
    // TODO: Implement actual audio metadata deletion
    print('OfflineQueue: Processing audio metadata deletion for ${operation.entityId}');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate processing
  }
}
