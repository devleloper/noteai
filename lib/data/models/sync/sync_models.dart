import 'package:equatable/equatable.dart';

/// Base class for all sync-related data models
abstract class SyncModel extends Equatable {
  const SyncModel();
}

/// Device information for cross-device synchronization
class DeviceInfo extends SyncModel {
  final String deviceId;
  final String deviceName;
  final String platform;
  final String appVersion;
  final DateTime lastSeen;
  final bool isOnline;
  final String? userId;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.appVersion,
    required this.lastSeen,
    required this.isOnline,
    this.userId,
  });

  @override
  List<Object?> get props => [
        deviceId,
        deviceName,
        platform,
        appVersion,
        lastSeen,
        isOnline,
        userId,
      ];

  DeviceInfo copyWith({
    String? deviceId,
    String? deviceName,
    String? platform,
    String? appVersion,
    DateTime? lastSeen,
    bool? isOnline,
    String? userId,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'platform': platform,
      'appVersion': appVersion,
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
      'userId': userId,
    };
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      platform: json['platform'] as String,
      appVersion: json['appVersion'] as String,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      isOnline: json['isOnline'] as bool,
      userId: json['userId'] as String?,
    );
  }
}

/// Sync status for tracking synchronization state
class SyncStatus extends SyncModel {
  final String id;
  final SyncState state;
  final DateTime? lastSync;
  final int pendingOperations;
  final String? error;
  final DateTime? nextRetry;

  const SyncStatus({
    required this.id,
    required this.state,
    this.lastSync,
    required this.pendingOperations,
    this.error,
    this.nextRetry,
  });

  @override
  List<Object?> get props => [
        id,
        state,
        lastSync,
        pendingOperations,
        error,
        nextRetry,
      ];

  SyncStatus copyWith({
    String? id,
    SyncState? state,
    DateTime? lastSync,
    int? pendingOperations,
    String? error,
    DateTime? nextRetry,
  }) {
    return SyncStatus(
      id: id ?? this.id,
      state: state ?? this.state,
      lastSync: lastSync ?? this.lastSync,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      error: error ?? this.error,
      nextRetry: nextRetry ?? this.nextRetry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state.name,
      'lastSync': lastSync?.toIso8601String(),
      'pendingOperations': pendingOperations,
      'error': error,
      'nextRetry': nextRetry?.toIso8601String(),
    };
  }
}

/// Sync states for tracking synchronization progress
enum SyncState {
  idle,
  syncing,
  error,
  offline,
  conflict,
}

/// Conflict resolution data for handling data conflicts
class ConflictData extends SyncModel {
  final String id;
  final String type;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime localTimestamp;
  final DateTime remoteTimestamp;
  final String? resolution;

  const ConflictData({
    required this.id,
    required this.type,
    required this.localData,
    required this.remoteData,
    required this.localTimestamp,
    required this.remoteTimestamp,
    this.resolution,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        localData,
        remoteData,
        localTimestamp,
        remoteTimestamp,
        resolution,
      ];

  ConflictData copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    DateTime? localTimestamp,
    DateTime? remoteTimestamp,
    String? resolution,
  }) {
    return ConflictData(
      id: id ?? this.id,
      type: type ?? this.type,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      localTimestamp: localTimestamp ?? this.localTimestamp,
      remoteTimestamp: remoteTimestamp ?? this.remoteTimestamp,
      resolution: resolution ?? this.resolution,
    );
  }
}

/// Audio metadata for cross-device audio synchronization
class AudioMetadata extends SyncModel {
  final String recordingId;
  final String fileName;
  final String filePath;
  final int fileSize;
  final Duration duration;
  final String format;
  final DateTime createdAt;
  final String deviceId;
  final String? transcriptionId;
  final bool isLocal;

  const AudioMetadata({
    required this.recordingId,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.duration,
    required this.format,
    required this.createdAt,
    required this.deviceId,
    this.transcriptionId,
    required this.isLocal,
  });

  @override
  List<Object?> get props => [
        recordingId,
        fileName,
        filePath,
        fileSize,
        duration,
        format,
        createdAt,
        deviceId,
        transcriptionId,
        isLocal,
      ];

  AudioMetadata copyWith({
    String? recordingId,
    String? fileName,
    String? filePath,
    int? fileSize,
    Duration? duration,
    String? format,
    DateTime? createdAt,
    String? deviceId,
    String? transcriptionId,
    bool? isLocal,
  }) {
    return AudioMetadata(
      recordingId: recordingId ?? this.recordingId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      duration: duration ?? this.duration,
      format: format ?? this.format,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId ?? this.deviceId,
      transcriptionId: transcriptionId ?? this.transcriptionId,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordingId': recordingId,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'duration': duration.inMilliseconds,
      'format': format,
      'createdAt': createdAt.toIso8601String(),
      'deviceId': deviceId,
      'transcriptionId': transcriptionId,
      'isLocal': isLocal,
    };
  }

  factory AudioMetadata.fromJson(Map<String, dynamic> json) {
    return AudioMetadata(
      recordingId: json['recordingId'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      duration: Duration(milliseconds: json['duration'] as int),
      format: json['format'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deviceId: json['deviceId'] as String,
      transcriptionId: json['transcriptionId'] as String?,
      isLocal: json['isLocal'] as bool,
    );
  }
}

/// Sync operation for queuing operations when offline
class SyncOperation extends SyncModel {
  final String id;
  final String type;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  final String? error;

  const SyncOperation({
    required this.id,
    required this.type,
    required this.entityId,
    required this.data,
    required this.timestamp,
    required this.retryCount,
    this.error,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        entityId,
        data,
        timestamp,
        retryCount,
        error,
      ];

  SyncOperation copyWith({
    String? id,
    String? type,
    String? entityId,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
    String? error,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
    );
  }
}
