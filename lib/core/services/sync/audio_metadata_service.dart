import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/sync/sync_models.dart';
import '../../../core/services/sync/firestore_sync_manager.dart';
import '../../../core/services/sync/smart_cache.dart';
import '../../../core/services/sync/offline_queue.dart';

/// Service for managing audio metadata synchronization
class AudioMetadataService {
  static final AudioMetadataService _instance = AudioMetadataService._internal();
  factory AudioMetadataService() => _instance;
  AudioMetadataService._internal();

  late FirestoreSyncManager _firestoreSyncManager;
  late SmartCache _smartCache;
  late OfflineQueue _offlineQueue;
  
  String? _currentUserId;
  String? _currentDeviceId;

  /// Initialize the service
  Future<void> initialize() async {
    _firestoreSyncManager = FirestoreSyncManager();
    _smartCache = SmartCache();
    _offlineQueue = OfflineQueue();
    
    await _firestoreSyncManager.initialize();
    await _smartCache.initialize();
    await _offlineQueue.initialize();
    
    _currentDeviceId = await _getDeviceId();
    print('AudioMetadataService: Initialized');
  }

  /// Get device ID (simplified implementation)
  Future<String> _getDeviceId() async {
    // TODO: Implement proper device ID retrieval
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Create audio metadata for a recording
  Future<AudioMetadata> createAudioMetadata({
    required String recordingId,
    required String filePath,
    required Duration duration,
  }) async {
    final file = File(filePath);
    final fileName = file.path.split('/').last;
    final fileSize = await file.length();
    final format = fileName.split('.').last.toLowerCase();
    
    final metadata = AudioMetadata(
      recordingId: recordingId,
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      duration: duration,
      format: format,
      createdAt: DateTime.now(),
      deviceId: _currentDeviceId ?? 'unknown',
      isLocal: true,
    );

    // Cache locally
    await _smartCache.cacheAudioMetadata(metadata);
    
    // Sync to Firestore if online
    await _syncAudioMetadataToFirestore(metadata);
    
    return metadata;
  }

  /// Sync audio metadata to Firestore
  Future<void> _syncAudioMetadataToFirestore(AudioMetadata metadata) async {
    try {
      await _firestoreSyncManager.syncAudioMetadata(metadata);
      print('AudioMetadataService: Synced metadata for ${metadata.recordingId}');
    } catch (e) {
      print('AudioMetadataService: Error syncing metadata: $e');
      // Add to offline queue
      await _offlineQueue.addOperation(SyncOperation(
        id: 'audio_metadata_${metadata.recordingId}',
        type: 'create',
        entityId: metadata.recordingId,
        data: metadata.toJson(),
        timestamp: DateTime.now(),
        retryCount: 0,
      ));
    }
  }

  /// Get audio metadata for a recording
  Future<AudioMetadata?> getAudioMetadata(String recordingId) async {
    // Try cache first
    final cachedMetadataList = await _smartCache.getAllCachedAudioMetadata();
    final cachedMetadata = cachedMetadataList.where((m) => m.recordingId == recordingId).firstOrNull;
    if (cachedMetadata != null) {
      return cachedMetadata;
    }

    // Try Firestore
    try {
      final remoteMetadata = await _firestoreSyncManager.getAudioMetadata(recordingId);
      if (remoteMetadata != null) {
        // Cache the remote metadata
        await _smartCache.cacheAudioMetadata(remoteMetadata);
        return remoteMetadata;
      }
    } catch (e) {
      print('AudioMetadataService: Error fetching metadata from Firestore: $e');
    }

    return null;
  }

  /// Get all audio metadata for current user
  Future<List<AudioMetadata>> getAllAudioMetadata() async {
    final allMetadata = <AudioMetadata>[];
    
    // Get cached metadata
    final cachedMetadata = await _smartCache.getAllCachedAudioMetadata();
    allMetadata.addAll(cachedMetadata);
    
    // Get remote metadata
    try {
      final remoteMetadata = await _firestoreSyncManager.getAllAudioMetadata();
      for (final metadata in remoteMetadata) {
        if (!allMetadata.any((m) => m.recordingId == metadata.recordingId)) {
          allMetadata.add(metadata);
          // Cache remote metadata
          await _smartCache.cacheAudioMetadata(metadata);
        }
      }
    } catch (e) {
      print('AudioMetadataService: Error fetching all metadata: $e');
    }
    
    return allMetadata;
  }

  /// Check if audio file is available locally
  Future<bool> isAudioFileLocal(String recordingId) async {
    final metadata = await getAudioMetadata(recordingId);
    if (metadata == null) return false;
    
    if (metadata.isLocal) {
      final file = File(metadata.filePath);
      return await file.exists();
    }
    
    return false;
  }

  /// Get local audio file path
  Future<String?> getLocalAudioPath(String recordingId) async {
    final metadata = await getAudioMetadata(recordingId);
    if (metadata == null || !metadata.isLocal) return null;
    
    final file = File(metadata.filePath);
    if (await file.exists()) {
      return metadata.filePath;
    }
    
    return null;
  }

  /// Download remote audio file (placeholder implementation)
  Future<String?> downloadRemoteAudio(String recordingId) async {
    final metadata = await getAudioMetadata(recordingId);
    if (metadata == null || metadata.isLocal) return null;
    
    try {
      // TODO: Implement actual audio file download from Firestore Storage
      // For now, return null as audio files are not stored in cloud
      print('AudioMetadataService: Audio file download not implemented yet');
      return null;
    } catch (e) {
      print('AudioMetadataService: Error downloading audio: $e');
      return null;
    }
  }

  /// Update audio metadata
  Future<void> updateAudioMetadata(AudioMetadata metadata) async {
    // Update cache
    await _smartCache.cacheAudioMetadata(metadata);
    
    // Sync to Firestore
    await _syncAudioMetadataToFirestore(metadata);
  }

  /// Delete audio metadata
  Future<void> deleteAudioMetadata(String recordingId) async {
    // Remove from cache
    await _smartCache.removeCachedAudioMetadata(recordingId);
    
    // Remove from Firestore
    try {
      await _firestoreSyncManager.deleteAudioMetadata(recordingId);
    } catch (e) {
      print('AudioMetadataService: Error deleting metadata: $e');
      // Add to offline queue
      await _offlineQueue.addOperation(SyncOperation(
        id: 'delete_audio_metadata_$recordingId',
        type: 'delete',
        entityId: recordingId,
        data: {},
        timestamp: DateTime.now(),
        retryCount: 0,
      ));
    }
  }

  /// Set current user ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  /// Dispose resources
  void dispose() {
    print('AudioMetadataService: Disposed');
  }
}
