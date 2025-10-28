import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recording_bloc.dart';
import '../bloc/recording_event.dart';
import '../bloc/recording_state.dart';
import 'stealth_recording_screen.dart';

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
          } else if (state is StealthActivating) {
            // Navigate to stealth screen when activation starts
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const StealthRecordingScreen(),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Recording Status
                  Text(
                    _getStatusText(state),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Recording Icon Button with Long Press Support
                  Center(
                    child: GestureDetector(
                      onTap: () => _handleMainAction(state),
                      onLongPressStart: (_) => _handleLongPressStart(state),
                      onLongPressEnd: (_) => _handleLongPressEnd(),
                      onLongPressCancel: _handleLongPressCancel,
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
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Recording Info
                  if (state is RecordingInProgress) ...[
                    Text(
                      'Duration: ${_formatDuration(state.duration)}',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Recording in progress...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  // Instruction Text
                  Text(
                    state is RecordingInProgress 
                        ? 'Tap the red button to stop recording'
                        : 'Tap to start recording • Long-press for stealth mode',
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
                  ],
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

  void _handleLongPressStart(RecordingState state) {
    if (state is! RecordingInProgress && state is! RecordingLoading) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleLongPressEnd() {
    // Long press completed - activate stealth mode
    context.read<RecordingBloc>().add(const StealthModeRequested());
  }

  void _handleLongPressCancel() {
    // Long press cancelled - do nothing
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
