import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../data/models/sync/sync_models.dart';

/// Central service for managing cross-device synchronization
class CrossDeviceSyncService {
  static final CrossDeviceSyncService _instance = CrossDeviceSyncService._internal();
  factory CrossDeviceSyncService() => _instance;
  CrossDeviceSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<DocumentSnapshot>? _syncStatusSubscription;
  
  String? _currentUserId;
  String? _currentDeviceId;
  bool _isOnline = false;
  SyncStatus _syncStatus = const SyncStatus(
    id: 'sync',
    state: SyncState.idle,
    lastSync: null,
    pendingOperations: 0,
  );

  /// Initialize the sync service
  Future<void> initialize() async {
    try {
      // Get current user
      _currentUserId = _auth.currentUser?.uid;
      if (_currentUserId == null) {
        print('CrossDeviceSyncService: No authenticated user');
        return;
      }

      // Generate or get device ID
      _currentDeviceId = await _getOrCreateDeviceId();
      
      // Register device
      await _registerDevice();
      
      // Start connectivity monitoring
      _startConnectivityMonitoring();
      
      // Start sync status monitoring
      _startSyncStatusMonitoring();
      
      print('CrossDeviceSyncService: Initialized successfully');
    } catch (e) {
      print('CrossDeviceSyncService: Initialization failed: $e');
    }
  }

  /// Get current sync status
  SyncStatus get syncStatus => _syncStatus;

  /// Check if device is online
  bool get isOnline => _isOnline;

  /// Get current device ID
  String? get currentDeviceId => _currentDeviceId;

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Start synchronization process
  Future<void> startSync() async {
    if (!_isOnline || _currentUserId == null) {
      print('CrossDeviceSyncService: Cannot sync - offline or no user');
      return;
    }

    try {
      _updateSyncStatus(SyncState.syncing);
      
      // Sync transcripts
      await _syncTranscripts();
      
      // Sync chat conversations
      await _syncChats();
      
      // Sync audio metadata
      await _syncAudioMetadata();
      
      // Process offline queue
      await _processOfflineQueue();
      
      _updateSyncStatus(SyncState.idle);
      print('CrossDeviceSyncService: Sync completed successfully');
    } catch (e) {
      _updateSyncStatus(SyncState.error, error: e.toString());
      print('CrossDeviceSyncService: Sync failed: $e');
    }
  }

  /// Stop synchronization
  Future<void> stopSync() async {
    try {
      _updateSyncStatus(SyncState.idle);
      print('CrossDeviceSyncService: Sync stopped');
    } catch (e) {
      print('CrossDeviceSyncService: Error stopping sync: $e');
    }
  }

  /// Force synchronization (ignore conflicts)
  Future<void> forceSync() async {
    final user = _auth.currentUser;
    if (!_isOnline || user == null) {
      print('CrossDeviceSyncService: Cannot force sync - offline or no user');
      return;
    }

    try {
      _updateSyncStatus(SyncState.syncing);
      
      // Force sync all data
      await _forceSyncTranscripts();
      await _forceSyncChats();
      await _forceSyncAudioMetadata();
      
      _updateSyncStatus(SyncState.idle);
      print('CrossDeviceSyncService: Force sync completed');
    } catch (e) {
      _updateSyncStatus(SyncState.error, error: e.toString());
      print('CrossDeviceSyncService: Force sync failed: $e');
    }
  }

  /// Resolve data conflicts
  Future<void> resolveConflicts(List<ConflictData> conflicts) async {
    for (final conflict in conflicts) {
      try {
        // Use timestamp-based resolution
        final resolution = _resolveConflict(conflict);
        await _applyConflictResolution(conflict, resolution);
      } catch (e) {
        print('CrossDeviceSyncService: Error resolving conflict ${conflict.id}: $e');
      }
    }
  }

  /// Add operation to offline queue
  Future<void> queueOfflineOperation(SyncOperation operation) async {
    try {
      // Store operation locally for later sync
      await _storeOfflineOperation(operation);
      print('CrossDeviceSyncService: Operation queued for offline sync');
    } catch (e) {
      print('CrossDeviceSyncService: Error queuing operation: $e');
    }
  }

  /// Get pending operations count
  int get pendingOperationsCount {
    return _syncStatus.pendingOperations;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _syncStatusSubscription?.cancel();
    print('CrossDeviceSyncService: Disposed');
  }

  // Private methods

  Future<String> _getOrCreateDeviceId() async {
    // Try to get existing device ID from local storage
    // For now, generate a new one (in real implementation, use device_info_plus)
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _registerDevice() async {
    if (_currentUserId == null || _currentDeviceId == null) return;

    final deviceInfo = DeviceInfo(
      deviceId: _currentDeviceId!,
      deviceName: Platform.isIOS ? 'iOS Device' : 'Android Device',
      platform: Platform.operatingSystem,
      appVersion: '1.0.0', // Get from package_info_plus
      lastSeen: DateTime.now(),
      isOnline: _isOnline,
      userId: _currentUserId,
    );

    await _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('devices')
        .doc(_currentDeviceId)
        .set(deviceInfo.toJson());
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final wasOnline = _isOnline;
        _isOnline = results.any((result) => 
          result == ConnectivityResult.mobile || 
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet
        );

        if (!wasOnline && _isOnline) {
          // Came back online, start sync
          startSync();
        } else if (wasOnline && !_isOnline) {
          // Went offline
          _updateSyncStatus(SyncState.offline);
        }
      },
    );
  }

  void _startSyncStatusMonitoring() {
    if (_currentUserId == null) return;

    _syncStatusSubscription = _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('syncStatus')
        .doc('status')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        _syncStatus = SyncStatus(
          id: data['id'] ?? 'sync',
          state: SyncState.values.firstWhere(
            (state) => state.name == data['state'],
            orElse: () => SyncState.idle,
          ),
          lastSync: data['lastSync'] != null 
            ? DateTime.parse(data['lastSync']) 
            : null,
          pendingOperations: data['pendingOperations'] ?? 0,
          error: data['error'],
          nextRetry: data['nextRetry'] != null 
            ? DateTime.parse(data['nextRetry']) 
            : null,
        );
      }
    });
  }

  void _updateSyncStatus(SyncState state, {String? error}) {
    _syncStatus = _syncStatus.copyWith(
      state: state,
      lastSync: DateTime.now(),
      error: error,
    );

    // Update Firestore
    if (_currentUserId != null) {
      _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('syncStatus')
          .doc('status')
          .set(_syncStatus.toJson());
    }
  }

  Future<void> _syncTranscripts() async {
    // Implementation for syncing transcripts
    print('CrossDeviceSyncService: Syncing transcripts...');
    // TODO: Implement transcript synchronization
  }

  Future<void> _syncChats() async {
    // Implementation for syncing chat conversations
    print('CrossDeviceSyncService: Syncing chats...');
    // TODO: Implement chat synchronization
  }

  Future<void> _syncAudioMetadata() async {
    // Implementation for syncing audio metadata
    print('CrossDeviceSyncService: Syncing audio metadata...');
    // TODO: Implement audio metadata synchronization
  }

  Future<void> _processOfflineQueue() async {
    // Implementation for processing offline operations
    print('CrossDeviceSyncService: Processing offline queue...');
    // TODO: Implement offline queue processing
  }

  Future<void> _forceSyncTranscripts() async {
    // Implementation for force syncing transcripts
    print('CrossDeviceSyncService: Force syncing transcripts...');
    // TODO: Implement force transcript synchronization
  }

  Future<void> _forceSyncChats() async {
    // Implementation for force syncing chats
    print('CrossDeviceSyncService: Force syncing chats...');
    // TODO: Implement force chat synchronization
  }

  Future<void> _forceSyncAudioMetadata() async {
    // Implementation for force syncing audio metadata
    print('CrossDeviceSyncService: Force syncing audio metadata...');
    // TODO: Implement force audio metadata synchronization
  }

  String _resolveConflict(ConflictData conflict) {
    // Timestamp-based conflict resolution
    if (conflict.localTimestamp.isAfter(conflict.remoteTimestamp)) {
      return 'local';
    } else if (conflict.remoteTimestamp.isAfter(conflict.localTimestamp)) {
      return 'remote';
    } else {
      // Same timestamp, prefer local
      return 'local';
    }
  }

  Future<void> _applyConflictResolution(ConflictData conflict, String resolution) async {
    // Implementation for applying conflict resolution
    print('CrossDeviceSyncService: Resolving conflict ${conflict.id} with $resolution');
    // TODO: Implement conflict resolution application
  }

  Future<void> _storeOfflineOperation(SyncOperation operation) async {
    // Implementation for storing offline operations
    print('CrossDeviceSyncService: Storing offline operation ${operation.id}');
    // TODO: Implement offline operation storage
  }
}
