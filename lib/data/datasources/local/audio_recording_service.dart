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

  // Optimized recording configuration for Whisper API
  static const int _optimalSampleRate = 16000;  // Optimal for speech recognition
  static const int _optimalBitRate = 80000;     // Sufficient for voice quality
  static const int _optimalChannels = 1;        // Mono for speech
  static const AudioEncoder _optimalEncoder = AudioEncoder.aacLc; // Best for Whisper

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
  
  // Configuration getters for monitoring and debugging
  int get optimalSampleRate => _optimalSampleRate;
  int get optimalBitRate => _optimalBitRate;
  int get optimalChannels => _optimalChannels;
  AudioEncoder get optimalEncoder => _optimalEncoder;

  Future<void> initialize() async {
    // Request microphone permission
    await _requestMicrophonePermission();
    
    // Log optimized configuration
    print('AudioRecordingService: Initialized with optimized settings for Whisper API');
    print('  - Sample Rate: ${_optimalSampleRate}Hz (optimal for speech recognition)');
    print('  - Bit Rate: ${_optimalBitRate}bps (sufficient for voice quality)');
    print('  - Channels: ${_optimalChannels} (mono for speech)');
    print('  - Encoder: ${_optimalEncoder.name} (best for Whisper)');
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

      // Start recording with optimized settings for Whisper API
      await _recorder.start(
        RecordConfig(
          encoder: _optimalEncoder,
          bitRate: _optimalBitRate,
          sampleRate: _optimalSampleRate,
          numChannels: _optimalChannels,
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
        
        // Log file size for monitoring optimization effectiveness
        final finalPath = path ?? _currentRecordingPath ?? '';
        if (finalPath.isNotEmpty) {
          await _logFileSize(finalPath);
        }
        
        _isRecording = false;
        _currentRecordingPath = null;
        // Don't reset duration here - let the repository get the final duration
        // _recordingDuration = Duration.zero;
        
        return finalPath;
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

  Future<void> _logFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();
        final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
        final durationMinutes = _recordingDuration.inMinutes;
        final durationSeconds = _recordingDuration.inSeconds % 60;
        
        print('AudioRecordingService: Recording completed');
        print('  - File: ${file.path.split('/').last}');
        print('  - Size: ${fileSizeMB}MB (${fileSize} bytes)');
        print('  - Duration: ${durationMinutes}m ${durationSeconds}s');
        print('  - Settings: ${_optimalSampleRate}Hz, ${_optimalBitRate}bps, ${_optimalChannels}ch');
        
        // Check if file is within Whisper API limits
        const whisperLimitBytes = 25 * 1024 * 1024; // 25MB
        if (fileSize > whisperLimitBytes) {
          print('  - ⚠️  WARNING: File exceeds Whisper API limit (25MB)');
        } else {
          print('  - ✅ File size is within Whisper API limits');
        }
      }
    } catch (e) {
      print('AudioRecordingService: Error logging file size: $e');
    }
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
