import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/sync/sync_models.dart';
import '../../../core/services/sync/audio_metadata_service.dart';

/// Service for managing remote audio playback
class RemoteAudioService {
  static final RemoteAudioService _instance = RemoteAudioService._internal();
  factory RemoteAudioService() => _instance;
  RemoteAudioService._internal();

  late AudioMetadataService _audioMetadataService;
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, bool> _downloadStatus = {};
  final Map<String, String?> _downloadedPaths = {};

  /// Initialize the service
  Future<void> initialize() async {
    _audioMetadataService = AudioMetadataService();
    await _audioMetadataService.initialize();
    print('RemoteAudioService: Initialized');
  }

  /// Check if audio is available locally
  Future<bool> isAudioLocal(String recordingId) async {
    return await _audioMetadataService.isAudioFileLocal(recordingId);
  }

  /// Get local audio path
  Future<String?> getLocalAudioPath(String recordingId) async {
    return await _audioMetadataService.getLocalAudioPath(recordingId);
  }

  /// Download remote audio file
  Future<String?> downloadRemoteAudio(String recordingId) async {
    if (_downloadStatus[recordingId] == true) {
      return _downloadedPaths[recordingId];
    }

    _downloadStatus[recordingId] = true;
    
    try {
      // For now, return null as audio files are not stored in cloud
      // This is a placeholder for future implementation
      print('RemoteAudioService: Audio download not implemented yet');
      
      // Simulate download delay
      await Future.delayed(const Duration(seconds: 2));
      
      _downloadStatus[recordingId] = false;
      return null;
    } catch (e) {
      print('RemoteAudioService: Error downloading audio: $e');
      _downloadStatus[recordingId] = false;
      return null;
    }
  }

  /// Check if audio is downloading
  bool isDownloading(String recordingId) {
    return _downloadStatus[recordingId] == true;
  }

  /// Check if audio is downloaded
  bool isDownloaded(String recordingId) {
    return _downloadedPaths[recordingId] != null;
  }

  /// Play audio (local or remote)
  Future<void> playAudio(String recordingId) async {
    try {
      // Check if we have a local file
      final localPath = await getLocalAudioPath(recordingId);
      if (localPath != null) {
        await _playLocalAudio(recordingId, localPath);
        return;
      }

      // Try to download remote audio
      final downloadedPath = await downloadRemoteAudio(recordingId);
      if (downloadedPath != null) {
        await _playLocalAudio(recordingId, downloadedPath);
        return;
      }

      // Show error - no audio available
      print('RemoteAudioService: No audio available for $recordingId');
    } catch (e) {
      print('RemoteAudioService: Error playing audio: $e');
    }
  }

  /// Play local audio file
  Future<void> _playLocalAudio(String recordingId, String filePath) async {
    try {
      // Dispose existing player if any
      await _disposePlayer(recordingId);

      // Create new player
      final player = AudioPlayer();
      _audioPlayers[recordingId] = player;

      // Set audio source
      await player.setFilePath(filePath);

      // Play audio
      await player.play();
      
      print('RemoteAudioService: Playing audio for $recordingId');
    } catch (e) {
      print('RemoteAudioService: Error playing local audio: $e');
    }
  }

  /// Pause audio
  Future<void> pauseAudio(String recordingId) async {
    final player = _audioPlayers[recordingId];
    if (player != null) {
      await player.pause();
    }
  }

  /// Stop audio
  Future<void> stopAudio(String recordingId) async {
    final player = _audioPlayers[recordingId];
    if (player != null) {
      await player.stop();
    }
  }

  /// Get audio player for a recording
  AudioPlayer? getAudioPlayer(String recordingId) {
    return _audioPlayers[recordingId];
  }

  /// Get audio duration
  Future<Duration?> getAudioDuration(String recordingId) async {
    final player = _audioPlayers[recordingId];
    if (player != null) {
      return player.duration;
    }

    // Try to get duration from metadata
    final metadata = await _audioMetadataService.getAudioMetadata(recordingId);
    return metadata?.duration;
  }

  /// Get current position
  Future<Duration?> getCurrentPosition(String recordingId) async {
    final player = _audioPlayers[recordingId];
    if (player != null) {
      return player.position;
    }
    return null;
  }

  /// Seek to position
  Future<void> seekTo(String recordingId, Duration position) async {
    final player = _audioPlayers[recordingId];
    if (player != null) {
      await player.seek(position);
    }
  }

  /// Dispose player for a recording
  Future<void> _disposePlayer(String recordingId) async {
    final player = _audioPlayers[recordingId];
    if (player != null) {
      await player.dispose();
      _audioPlayers.remove(recordingId);
    }
  }

  /// Dispose all players
  Future<void> dispose() async {
    for (final player in _audioPlayers.values) {
      await player.dispose();
    }
    _audioPlayers.clear();
    _downloadStatus.clear();
    _downloadedPaths.clear();
    print('RemoteAudioService: Disposed');
  }
}
