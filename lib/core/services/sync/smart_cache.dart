import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/sync/sync_models.dart';

/// Intelligent local caching system for cross-device sync
class SmartCache {
  static final SmartCache _instance = SmartCache._internal();
  factory SmartCache() => _instance;
  SmartCache._internal();

  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  static const String _cachePrefix = 'sync_cache_';
  static const String _timestampPrefix = 'sync_timestamp_';
  static const Duration _defaultCacheExpiry = Duration(hours: 24);

  /// Initialize the cache
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('SmartCache: Initialized');
  }

  /// Get all cached transcripts
  Future<List<Map<String, dynamic>>> getAllCachedTranscripts() async {
    if (_prefs == null) return [];
    
    try {
      final keys = _prefs!.getKeys().where((key) => key.startsWith('${_cachePrefix}transcript_'));
      final transcripts = <Map<String, dynamic>>[];
      
      for (final key in keys) {
        final jsonString = _prefs!.getString(key);
        if (jsonString != null) {
          final data = jsonDecode(jsonString) as Map<String, dynamic>;
          if (!_isExpired(data['cachedAt'] as String?)) {
            transcripts.add(data);
          }
        }
      }
      
      return transcripts;
    } catch (e) {
      print('SmartCache: Error getting cached transcripts: $e');
      return [];
    }
  }

  /// Check if cache entry is expired
  bool _isExpired(String? cachedAtString) {
    if (cachedAtString == null) return true;
    
    try {
      final cachedAt = DateTime.parse(cachedAtString);
      return DateTime.now().difference(cachedAt) > _defaultCacheExpiry;
    } catch (e) {
      return true;
    }
  }

  /// Cache transcript data
  Future<void> cacheTranscript({
    required String transcriptId,
    required String content,
    required String recordingId,
    required DateTime updatedAt,
  }) async {
    final key = '${_cachePrefix}transcript_$transcriptId';
    final data = {
      'transcriptId': transcriptId,
      'content': content,
      'recordingId': recordingId,
      'updatedAt': updatedAt.toIso8601String(),
      'cachedAt': DateTime.now().toIso8601String(),
    };

    await _setCache(key, data);
    print('SmartCache: Transcript $transcriptId cached');
  }

  /// Get cached transcript
  Future<Map<String, dynamic>?> getCachedTranscript(String transcriptId) async {
    final key = '${_cachePrefix}transcript_$transcriptId';
    final data = await _getCache(key);
    
    if (data != null && _isCacheValid(key)) {
      return data;
    }
    
    return null;
  }

  /// Cache chat messages
  Future<void> cacheChatMessages({
    required String recordingId,
    required List<Map<String, dynamic>> messages,
  }) async {
    final key = '${_cachePrefix}chat_$recordingId';
    final data = {
      'recordingId': recordingId,
      'messages': messages,
      'cachedAt': DateTime.now().toIso8601String(),
    };

    await _setCache(key, data);
    print('SmartCache: Chat messages for $recordingId cached');
  }

  /// Get cached chat messages
  Future<List<Map<String, dynamic>>?> getCachedChatMessages(String recordingId) async {
    final key = '${_cachePrefix}chat_$recordingId';
    final data = await _getCache(key);
    
    if (data != null && _isCacheValid(key)) {
      return List<Map<String, dynamic>>.from(data['messages'] ?? []);
    }
    
    return null;
  }

  /// Cache audio metadata
  Future<void> cacheAudioMetadata(AudioMetadata metadata) async {
    final key = '${_cachePrefix}audio_${metadata.recordingId}';
    final data = {
      ...metadata.toJson(),
      'cachedAt': DateTime.now().toIso8601String(),
    };

    await _setCache(key, data);
    print('SmartCache: Audio metadata ${metadata.recordingId} cached');
  }

  /// Get cached audio metadata
  Future<AudioMetadata?> getCachedAudioMetadata(String recordingId) async {
    final key = '${_cachePrefix}audio_$recordingId';
    final data = await _getCache(key);
    
    if (data != null && _isCacheValid(key)) {
      return AudioMetadata.fromJson(data);
    }
    
    return null;
  }

  /// Cache sync status
  Future<void> cacheSyncStatus(SyncStatus status) async {
    final key = '${_cachePrefix}sync_status';
    final data = {
      'id': status.id,
      'state': status.state.name,
      'lastSync': status.lastSync?.toIso8601String(),
      'pendingOperations': status.pendingOperations,
      'error': status.error,
      'nextRetry': status.nextRetry?.toIso8601String(),
      'cachedAt': DateTime.now().toIso8601String(),
    };

    await _setCache(key, data);
    print('SmartCache: Sync status cached');
  }

  /// Get cached sync status
  Future<SyncStatus?> getCachedSyncStatus() async {
    final key = '${_cachePrefix}sync_status';
    final data = await _getCache(key);
    
    if (data != null && _isCacheValid(key)) {
      return SyncStatus(
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
    
    return null;
  }

  /// Cache device info
  Future<void> cacheDeviceInfo(DeviceInfo deviceInfo) async {
    final key = '${_cachePrefix}device_${deviceInfo.deviceId}';
    final data = {
      ...deviceInfo.toJson(),
      'cachedAt': DateTime.now().toIso8601String(),
    };

    await _setCache(key, data);
    print('SmartCache: Device info ${deviceInfo.deviceId} cached');
  }

  /// Get cached device info
  Future<DeviceInfo?> getCachedDeviceInfo(String deviceId) async {
    final key = '${_cachePrefix}device_$deviceId';
    final data = await _getCache(key);
    
    if (data != null && _isCacheValid(key)) {
      return DeviceInfo.fromJson(data);
    }
    
    return null;
  }


  /// Get all cached chat recordings
  Future<List<String>> getAllCachedChatRecordings() async {
    final keys = await _getKeysWithPrefix('${_cachePrefix}chat_');
    return keys.map((key) => key.replaceFirst('${_cachePrefix}chat_', '')).toList();
  }

  /// Get all cached audio metadata
  Future<List<AudioMetadata>> getAllCachedAudioMetadata() async {
    final keys = await _getKeysWithPrefix('${_cachePrefix}audio_');
    final metadata = <AudioMetadata>[];

    for (final key in keys) {
      final data = await _getCache(key);
      if (data != null && _isCacheValid(key)) {
        try {
          metadata.add(AudioMetadata.fromJson(data));
        } catch (e) {
          print('SmartCache: Error parsing audio metadata: $e');
        }
      }
    }

    return metadata;
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    if (_prefs == null) return;

    final keys = _prefs!.getKeys();
    final expiredKeys = <String>[];

    for (final key in keys) {
      if (key.startsWith(_cachePrefix) && !_isCacheValid(key)) {
        expiredKeys.add(key);
      }
    }

    for (final key in expiredKeys) {
      await _prefs!.remove(key);
      final timestampKey = key.replaceFirst(_cachePrefix, _timestampPrefix);
      await _prefs!.remove(timestampKey);
    }

    print('SmartCache: Cleared ${expiredKeys.length} expired cache entries');
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    if (_prefs == null) return;

    final keys = _prefs!.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith(_cachePrefix)).toList();

    for (final key in cacheKeys) {
      await _prefs!.remove(key);
    }

    _memoryCache.clear();
    _cacheTimestamps.clear();
    print('SmartCache: All cache cleared');
  }

  /// Remove cached audio metadata
  Future<void> removeCachedAudioMetadata(String recordingId) async {
    if (_prefs == null) return;
    
    final key = '${_cachePrefix}audio_$recordingId';
    final timestampKey = '${_timestampPrefix}audio_$recordingId';
    
    await _prefs!.remove(key);
    await _prefs!.remove(timestampKey);
    
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    
    print('SmartCache: Removed cached audio metadata for $recordingId');
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    if (_prefs == null) return {};

    final keys = _prefs!.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith(_cachePrefix)).toList();
    
    int validEntries = 0;
    int expiredEntries = 0;
    int totalSize = 0;

    for (final key in cacheKeys) {
      if (_isCacheValid(key)) {
        validEntries++;
      } else {
        expiredEntries++;
      }
      
      final data = _prefs!.getString(key);
      if (data != null) {
        totalSize += data.length;
      }
    }

    return {
      'totalEntries': cacheKeys.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'totalSizeBytes': totalSize,
      'memoryCacheSize': _memoryCache.length,
    };
  }

  // Private methods

  Future<void> _setCache(String key, Map<String, dynamic> data) async {
    if (_prefs == null) return;

    final jsonString = jsonEncode(data);
    await _prefs!.setString(key, jsonString);
    
    // Store timestamp
    final timestampKey = key.replaceFirst(_cachePrefix, _timestampPrefix);
    await _prefs!.setString(timestampKey, DateTime.now().toIso8601String());
    
    // Update memory cache
    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  Future<Map<String, dynamic>?> _getCache(String key) async {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] as Map<String, dynamic>?;
    }

    // Check persistent storage
    if (_prefs == null) return null;
    
    final jsonString = _prefs!.getString(key);
    if (jsonString == null) return null;

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      _memoryCache[key] = data;
      return data;
    } catch (e) {
      print('SmartCache: Error parsing cached data for $key: $e');
      return null;
    }
  }

  bool _isCacheValid(String key) {
    if (_prefs == null) return false;

    final timestampKey = key.replaceFirst(_cachePrefix, _timestampPrefix);
    final timestampString = _prefs!.getString(timestampKey);
    
    if (timestampString == null) return false;

    try {
      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();
      return now.difference(timestamp) < _defaultCacheExpiry;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> _getKeysWithPrefix(String prefix) async {
    if (_prefs == null) return [];

    final keys = _prefs!.getKeys();
    return keys.where((key) => key.startsWith(prefix)).toList();
  }
}
