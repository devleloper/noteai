import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recording_bloc.dart';
import '../bloc/recording_event.dart';
import '../bloc/recording_state.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
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
            // Add small delay to ensure RecordingsLoaded is processed before navigation
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Recording Status
                  Text(
                    _getStatusText(state),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Recording Icon Button
                  GestureDetector(
                    onTap: () => _handleMainAction(state),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: state is RecordingInProgress 
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: (state is RecordingInProgress 
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        state is RecordingInProgress ? Icons.stop : Icons.mic,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Recording Info
                  if (state is RecordingInProgress) ...[
                    Text(
                      'Duration: ${_formatDuration(state.duration)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Recording in progress...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                  
                  // Instruction Text
                  Text(
                    state is RecordingInProgress 
                        ? 'Tap the red button to stop recording'
                        : 'Tap the blue button to start recording',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Title Input (only show when not recording)
                  if (state is! RecordingInProgress) ...[
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter recording title (optional)...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleMainAction(state),
                      icon: Icon(
                        state is RecordingInProgress ? Icons.stop : Icons.mic,
                      ),
                      label: Text(
                        state is RecordingInProgress ? 'Stop Recording' : 'Start Recording',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleMainAction(RecordingState state) {
    if (state is RecordingInProgress) {
      // Stop recording
      context.read<RecordingBloc>().add(
        StopRecordingRequested(state.recordingId),
      );
    } else {
      // Start recording
      context.read<RecordingBloc>().add(
        StartRecordingRequested(_titleController.text.trim()),
      );
    }
  }

  String _getStatusText(RecordingState state) {
    if (state is RecordingInProgress) {
      return 'Recording...';
    } else if (state is RecordingLoading) {
      return 'Starting...';
    } else {
      return 'Ready to Record';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
