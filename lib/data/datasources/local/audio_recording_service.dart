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

      // Initialize recording stream BEFORE starting recording (only if not already initialized)
      _recordingController ??= StreamController<RecordingData>.broadcast();

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


  Future<String> stopRecording() async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        _recordingTimer?.cancel();
        // Don't close the controller here - let it be reused for next recording
        // _recordingController?.close();
        
        _isRecording = false;
        _currentRecordingPath = null;
        // Don't reset duration here - let the repository get the final duration
        // _recordingDuration = Duration.zero;
        
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

  Duration get finalRecordingDuration => _recordingDuration;

  void resetRecordingState() {
    _recordingDuration = Duration.zero;
  }

  double _getRandomAmplitude() {
    // Generate more realistic amplitude values
    // Simulate audio amplitude with some variation
    final random = DateTime.now().millisecond / 1000.0;
    final baseAmplitude = 0.3 + (random * 0.4); // Base between 0.3-0.7
    final variation = (DateTime.now().microsecond % 100) / 1000.0; // Small variation
    return (baseAmplitude + variation).clamp(0.0, 1.0);
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
