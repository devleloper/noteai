import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recording_bloc.dart';
import '../bloc/recording_event.dart';
import '../bloc/recording_state.dart';
import '../../../../core/utils/service_locator.dart' as di;
import '../../../../data/datasources/local/audio_recording_service.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final TextEditingController _titleController = TextEditingController();
  late final AudioRecordingService _audioService;
  StreamSubscription<RecordingData>? _recordingSubscription;

  @override
  void initState() {
    super.initState();
    _audioService = di.sl<AudioRecordingService>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recordingSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Recording',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocConsumer<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state is RecordingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is RecordingCompleted) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Recording Status
                  Text(
                    _getStatusText(state),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Waveform Visualization
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildWaveformVisualizer(state),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Recording Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Stop Button
                      if (state is RecordingInProgress || state is RecordingPaused)
                        _buildControlButton(
                          icon: Icons.stop,
                          color: Colors.red,
                          onPressed: () {
                            if (state is RecordingInProgress) {
                              context.read<RecordingBloc>().add(
                                StopRecordingRequested((state as RecordingInProgress).recordingId),
                              );
                            } else if (state is RecordingPaused) {
                              context.read<RecordingBloc>().add(
                                StopRecordingRequested((state as RecordingPaused).recordingId),
                              );
                            }
                          },
                        ),
                      
                      // Main Record/Pause Button
                      _buildMainControlButton(state),
                      
                      // Options Button
                      _buildControlButton(
                        icon: Icons.more_vert,
                        color: Colors.white,
                        onPressed: () => _showRecordingOptions(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Recording Info
                  if (state is RecordingInProgress || state is RecordingPaused)
                    Text(
                      'Duration: ${_formatDuration(_getDuration(state))}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  
                  const SizedBox(height: 48),
                  
                  // Title Input (only show when not recording)
                  if (state is! RecordingInProgress && state is! RecordingPaused)
                    Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter recording title...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white54),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 48, color: color),
      onPressed: onPressed,
    );
  }

  Widget _buildMainControlButton(RecordingState state) {
    if (state is RecordingInProgress) {
      return GestureDetector(
        onTap: () {
          context.read<RecordingBloc>().add(
            PauseRecordingRequested((state as RecordingInProgress).recordingId),
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange,
          ),
          child: const Icon(
            Icons.pause,
            color: Colors.white,
            size: 40,
          ),
        ),
      );
    } else if (state is RecordingPaused) {
      return GestureDetector(
        onTap: () {
          context.read<RecordingBloc>().add(
            ResumeRecordingRequested((state as RecordingPaused).recordingId),
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
            size: 40,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (_titleController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a recording title'),
              ),
            );
            return;
          }
          
          context.read<RecordingBloc>().add(
            StartRecordingRequested(_titleController.text.trim()),
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
            size: 40,
          ),
        ),
      );
    }
  }

  Widget _buildWaveformVisualizer(RecordingState state) {
    if (state is RecordingInProgress) {
      return StreamBuilder<RecordingData>(
        stream: _audioService.recordingStream,
        builder: (context, snapshot) {
          final amplitude = snapshot.data?.amplitude ?? 0.0;
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(20, (index) {
                final height = 20 + (amplitude * 30);
                return Container(
                  width: 3,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Icon(
          Icons.mic,
          color: Colors.white54,
          size: 48,
        ),
      );
    }
  }

  String _getStatusText(RecordingState state) {
    if (state is RecordingInProgress) {
      return 'Recording...';
    } else if (state is RecordingPaused) {
      return 'Paused';
    } else if (state is RecordingLoading) {
      return 'Starting...';
    } else {
      return 'Ready to Record';
    }
  }

  Duration _getDuration(RecordingState state) {
    if (state is RecordingInProgress) {
      return state.duration;
    } else if (state is RecordingPaused) {
      return state.duration;
    }
    return Duration.zero;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showRecordingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Recording Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('Recording Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show recording info
              },
            ),
          ],
        ),
      ),
    );
  }
}
