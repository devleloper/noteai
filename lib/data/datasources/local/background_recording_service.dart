import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_recording_service.dart';

class BackgroundRecordingService {
  static const String _recordingKey = 'is_recording';
  static const String _recordingPathKey = 'recording_path';
  static const String _recordingTitleKey = 'recording_title';
  
  static final BackgroundRecordingService _instance = BackgroundRecordingService._internal();
  factory BackgroundRecordingService() => _instance;
  BackgroundRecordingService._internal();

  AudioRecordingService? _audioService;
  StreamController<RecordingData>? _recordingController;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  bool get isRecording => _audioService?.isRecording ?? false;
  Duration get recordingDuration => _recordingDuration;

  Future<void> initialize() async {
    // Initialize audio service
    _audioService = AudioRecordingService();
    await _audioService!.initialize();
  }

  Future<String> startBackgroundRecording(String title) async {
    try {
      if (_audioService == null) {
        await initialize();
      }

      // Create recording directory
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${title.replaceAll(' ', '_')}_$timestamp.aac';
      final recordingPath = '${recordingsDir.path}/$fileName';

      // Start recording
      await _audioService!.startRecording(title);
      
      // Store recording info in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_recordingKey, true);
      await prefs.setString(_recordingPathKey, recordingPath);
      await prefs.setString(_recordingTitleKey, title);

      // Note: Background task registration would go here
      // For now, we'll rely on the app staying active

      // Start duration timer
      _recordingDuration = Duration.zero;
      _recordingController = StreamController<RecordingData>.broadcast();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        _recordingController?.add(RecordingData(
          duration: _recordingDuration,
          amplitude: _getRandomAmplitude(),
        ));
      });

      return recordingPath;
    } catch (e) {
      throw RecordingException('Failed to start background recording: $e');
    }
  }

  Future<void> pauseBackgroundRecording() async {
    try {
      if (_audioService != null) {
        await _audioService!.pauseRecording();
        _recordingTimer?.cancel();
      }
    } catch (e) {
      throw RecordingException('Failed to pause background recording: $e');
    }
  }

  Future<void> resumeBackgroundRecording() async {
    try {
      if (_audioService != null) {
        await _audioService!.resumeRecording();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _recordingDuration = Duration(seconds: timer.tick);
          _recordingController?.add(RecordingData(
            duration: _recordingDuration,
            amplitude: _getRandomAmplitude(),
          ));
        });
      }
    } catch (e) {
      throw RecordingException('Failed to resume background recording: $e');
    }
  }

  Future<String> stopBackgroundRecording() async {
    try {
      if (_audioService != null) {
        final path = await _audioService!.stopRecording();
        
        // Clear recording info from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_recordingKey, false);
        await prefs.remove(_recordingPathKey);
        await prefs.remove(_recordingTitleKey);

        // Note: Background task cancellation would go here

        _recordingTimer?.cancel();
        await _recordingController?.close();
        _recordingDuration = Duration.zero;
        
        return path;
      }
      throw RecordingException('No active background recording to stop');
    } catch (e) {
      throw RecordingException('Failed to stop background recording: $e');
    }
  }

  Future<bool> isBackgroundRecordingActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_recordingKey) ?? false;
  }

  Future<String?> getCurrentRecordingPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_recordingPathKey);
  }

  Future<String?> getCurrentRecordingTitle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_recordingTitleKey);
  }

  Stream<RecordingData>? get recordingStream => _recordingController?.stream;

  double _getRandomAmplitude() {
    return (DateTime.now().millisecond % 100) / 100.0;
  }

  Future<void> dispose() async {
    _recordingTimer?.cancel();
    await _recordingController?.close();
    await _audioService?.dispose();
  }
}


// Note: WorkManager callback would go here when workmanager is re-enabled
