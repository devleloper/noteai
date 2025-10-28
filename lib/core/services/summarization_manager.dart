import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'summarization_service.dart';
import 'sync/offline_queue.dart';
import '../network/network_info.dart';

/// Manages summarization operations with network awareness and automatic retry
class SummarizationManager {
  final SummarizationService _summarizationService;
  final OfflineQueue _offlineQueue;
  final NetworkInfo _networkInfo;
  final Connectivity _connectivity;
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  
  static const Duration _retryInterval = Duration(minutes: 5);
  static const Duration _networkCheckInterval = Duration(seconds: 30);

  SummarizationManager({
    required SummarizationService summarizationService,
    required OfflineQueue offlineQueue,
    required NetworkInfo networkInfo,
    required Connectivity connectivity,
  }) : _summarizationService = summarizationService,
       _offlineQueue = offlineQueue,
       _networkInfo = networkInfo,
       _connectivity = connectivity;

  /// Initialize the summarization manager
  Future<void> initialize() async {
    // Initialize offline queue
    await _offlineQueue.initialize();
    
    // Start monitoring network connectivity
    _startConnectivityMonitoring();
    
    // Start periodic retry timer
    _startRetryTimer();
    
    // Process any pending summarizations on startup
    await _processPendingSummarizationsIfOnline();
  }

  /// Start monitoring network connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final isConnected = results.any((result) => result != ConnectivityResult.none);
        
        if (isConnected) {
          // Network is available, process pending summarizations
          await _processPendingSummarizationsIfOnline();
        }
      },
    );
  }

  /// Start periodic retry timer for failed summarizations
  void _startRetryTimer() {
    _retryTimer = Timer.periodic(_retryInterval, (timer) async {
      await _retryFailedSummarizations();
    });
  }

  /// Process pending summarizations if network is available
  Future<void> _processPendingSummarizationsIfOnline() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (isConnected) {
        await _summarizationService.processPendingSummarizations();
      }
    } catch (e) {
      print('Error processing pending summarizations: $e');
    }
  }

  /// Retry failed summarizations
  Future<void> _retryFailedSummarizations() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (isConnected) {
        await _summarizationService.retryFailedSummarizations();
      }
    } catch (e) {
      print('Error retrying failed summarizations: $e');
    }
  }

  /// Get summarization statistics
  Map<String, dynamic> getSummarizationStats() {
    return _summarizationService.getSummarizationStats();
  }

  /// Get offline queue statistics
  Map<String, dynamic> getOfflineQueueStats() {
    return _offlineQueue.getQueueStats();
  }

  /// Force process all pending operations
  Future<void> forceProcessPendingOperations() async {
    try {
      await _offlineQueue.processPendingOperations();
      await _summarizationService.processPendingSummarizations();
    } catch (e) {
      print('Error force processing pending operations: $e');
    }
  }

  /// Clear all pending summarizations
  Future<void> clearPendingSummarizations() async {
    try {
      final pendingOps = _offlineQueue.getPendingOperationsByType('summarization');
      for (final op in pendingOps) {
        await _offlineQueue.removeOperation(op.id);
      }
    } catch (e) {
      print('Error clearing pending summarizations: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _summarizationService.dispose();
  }
}
