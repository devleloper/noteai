import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  String? _currentRecordingPath;
  StreamController<RecordingData>? _recordingController;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  bool get isRecording => _recorder?.isRecording ?? false;
  bool get isPaused => _recorder?.isPaused ?? false;
  Duration get recordingDuration => _recordingDuration;

  Future<void> initialize() async {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    
    await _recorder?.openRecorder();
    await _player?.openPlayer();
    
    // Request microphone permission
    await _requestMicrophonePermission();
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<String> startRecording(String title) async {
    try {
      if (_recorder == null) {
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
      _currentRecordingPath = '${recordingsDir.path}/$fileName';

      // Start recording
      await _recorder?.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      // Start duration timer
      _recordingDuration = Duration.zero;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        _recordingController?.add(RecordingData(
          duration: _recordingDuration,
          amplitude: _getRandomAmplitude(), // Placeholder for now
        ));
      });

      // Initialize recording stream
      _recordingController = StreamController<RecordingData>.broadcast();

      return _currentRecordingPath!;
    } catch (e) {
      throw RecordingException('Failed to start recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    try {
      if (_recorder?.isRecording == true) {
        await _recorder?.pauseRecorder();
        _recordingTimer?.cancel();
      }
    } catch (e) {
      throw RecordingException('Failed to pause recording: $e');
    }
  }

  Future<void> resumeRecording() async {
    try {
      if (_recorder?.isPaused == true) {
        await _recorder?.resumeRecorder();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _recordingDuration = Duration(seconds: timer.tick);
          _recordingController?.add(RecordingData(
            duration: _recordingDuration,
            amplitude: _getRandomAmplitude(),
          ));
        });
      }
    } catch (e) {
      throw RecordingException('Failed to resume recording: $e');
    }
  }

  Future<String> stopRecording() async {
    try {
      if (_recorder?.isRecording == true || _recorder?.isPaused == true) {
        await _recorder?.stopRecorder();
        _recordingTimer?.cancel();
        _recordingController?.close();
        
        final path = _currentRecordingPath!;
        _currentRecordingPath = null;
        _recordingDuration = Duration.zero;
        
        return path;
      }
      throw RecordingException('No active recording to stop');
    } catch (e) {
      throw RecordingException('Failed to stop recording: $e');
    }
  }

  Future<void> playRecording(String filePath) async {
    try {
      if (_player == null) {
        await initialize();
      }
      
      await _player?.startPlayer(
        fromURI: filePath,
        codec: Codec.aacADTS,
      );
    } catch (e) {
      throw RecordingException('Failed to play recording: $e');
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player?.stopPlayer();
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
    await _recorder?.closeRecorder();
    await _player?.closePlayer();
    _recorder = null;
    _player = null;
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
