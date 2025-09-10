import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? _currentRecordingPath;
  StreamController<RecordingData>? _recordingController;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  bool get isPaused => false; // Record package doesn't support pause
  Duration get recordingDuration => _recordingDuration;

  Future<void> initialize() async {
    // Request microphone permission
    await _requestMicrophonePermission();
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<String> startRecording(String title) async {
    try {
      // Check if already recording
      if (_isRecording) {
        throw RecordingException('Recording is already in progress');
      }

      // Check if recorder is available
      if (!await _recorder.hasPermission()) {
        throw RecordingException('Microphone permission not granted');
      }

      // Create recording directory
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${title.replaceAll(' ', '_')}_$timestamp.m4a';
      _currentRecordingPath = '${recordingsDir.path}/$fileName';

      // Initialize recording stream BEFORE starting recording
      _recordingController = StreamController<RecordingData>.broadcast();

      // Start recording
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;

      // Start duration timer
      _recordingDuration = Duration.zero;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        _recordingController?.add(RecordingData(
          duration: _recordingDuration,
          amplitude: _getRandomAmplitude(), // Placeholder for now
        ));
      });

      return _currentRecordingPath!;
    } catch (e) {
      throw RecordingException('Failed to start recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    // Record package doesn't support pause/resume
    throw RecordingException('Pause/resume not supported by record package');
  }

  Future<void> resumeRecording() async {
    // Record package doesn't support pause/resume
    throw RecordingException('Pause/resume not supported by record package');
  }

  Future<String> stopRecording() async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        _recordingTimer?.cancel();
        _recordingController?.close();
        
        _isRecording = false;
        _currentRecordingPath = null;
        _recordingDuration = Duration.zero;
        
        return path ?? _currentRecordingPath ?? '';
      }
      throw RecordingException('No active recording to stop');
    } catch (e) {
      throw RecordingException('Failed to stop recording: $e');
    }
  }

  Future<void> playRecording(String filePath) async {
    try {
      await _player.play(DeviceFileSource(filePath));
    } catch (e) {
      throw RecordingException('Failed to play recording: $e');
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player.stop();
    } catch (e) {
      throw RecordingException('Failed to stop playback: $e');
    }
  }

  Stream<RecordingData>? get recordingStream => _recordingController?.stream;

  double _getRandomAmplitude() {
    // Placeholder for amplitude data
    // In a real implementation, this would come from the audio recorder
    return (DateTime.now().millisecond % 100) / 100.0;
  }

  Future<void> dispose() async {
    _recordingTimer?.cancel();
    await _recordingController?.close();
    await _recorder.dispose();
    await _player.dispose();
  }
}

class RecordingData {
  final Duration duration;
  final double amplitude;

  RecordingData({
    required this.duration,
    required this.amplitude,
  });
}

class RecordingException implements Exception {
  final String message;
  RecordingException(this.message);
  
  @override
  String toString() => 'RecordingException: $message';
}
