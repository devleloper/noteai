import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/recording.dart';
import '../../player/widgets/mini_player_widget.dart';
import '../../recording/bloc/recording_bloc.dart';
import '../../recording/bloc/recording_state.dart';
import '../../recording/bloc/recording_event.dart';
import '../../transcription/view/transcription_screen.dart';

class RecordingCard extends StatelessWidget {
  final Recording recording;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RecordingCard({
    super.key,
    required this.recording,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Debug logging to track state updates
    print('RecordingCard building for recording: ${recording.id}');
    print('Transcription status: ${recording.transcriptionStatus}');
    print('Has transcript: ${recording.transcript?.isNotEmpty ?? false}');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      recording.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDuration(recording.duration),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Status and progress
              Row(
                children: [
                  Icon(
                    _getStatusIcon(recording.status),
                    size: 16,
                    color: _getStatusColor(recording.status, context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusText(recording.status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(recording.status, context),
                    ),
                  ),
                  if (recording.progress < 1.0 && recording.status == RecordingStatus.processing) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: recording.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              // Transcription status
              if (recording.transcriptionStatus != TranscriptionStatus.notStarted) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTranscriptionStatusIndicator(context),
                    const SizedBox(width: 4),
                    Text(
                      _getTranscriptionStatusText(recording.transcriptionStatus),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getTranscriptionStatusColor(recording.transcriptionStatus, context),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context: context,
                    icon: Icons.play_arrow,
                    label: 'Play',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => MiniPlayerWidget(
                          recording: recording,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      );
                    },
                  ),
                  _buildTranscriptionButton(context),
                  _buildActionButton(
                    context: context,
                    icon: Icons.chat,
                    label: 'AI Chat',
                    onPressed: () {
                      // TODO: Navigate to AI chat
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.delete,
                    label: 'Delete',
                    onPressed: onDelete,
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDestructive = false,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDestructive
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.recording:
        return Icons.mic;
      case RecordingStatus.paused:
        return Icons.pause_circle;
      case RecordingStatus.completed:
        return Icons.check_circle;
      case RecordingStatus.processing:
        return Icons.sync;
      case RecordingStatus.transcribed:
        return Icons.text_snippet;
      case RecordingStatus.failed:
        return Icons.error;
    }
  }

  Color _getStatusColor(RecordingStatus status, BuildContext context) {
    switch (status) {
      case RecordingStatus.recording:
        return Colors.red;
      case RecordingStatus.paused:
        return Colors.orange;
      case RecordingStatus.completed:
        return Colors.green;
      case RecordingStatus.processing:
        return Theme.of(context).colorScheme.primary;
      case RecordingStatus.transcribed:
        return Colors.blue;
      case RecordingStatus.failed:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getStatusText(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.recording:
        return 'Recording';
      case RecordingStatus.paused:
        return 'Paused';
      case RecordingStatus.completed:
        return 'Completed';
      case RecordingStatus.processing:
        return 'Processing';
      case RecordingStatus.transcribed:
        return 'Transcribed';
      case RecordingStatus.failed:
        return 'Failed';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildTranscriptionButton(BuildContext context) {
    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        // Check if this recording is currently being transcribed
        bool isTranscribing = false;
        if (state is TranscriptionProcessing && state.recordingId == recording.id) {
          isTranscribing = true;
        }

        return _buildActionButton(
          context: context,
          icon: isTranscribing ? Icons.sync : Icons.text_snippet,
          label: isTranscribing ? 'Transcribing' : 'Transcribe',
          onPressed: () {
            print('Transcription button pressed for recording: ${recording.id}');
            print('Current transcription status: ${recording.transcriptionStatus}');
            print('Has transcript: ${recording.transcript?.isNotEmpty ?? false}');
            print('Transcript length: ${recording.transcript?.length ?? 0}');
            
            // Check for completed transcription or existing transcript
            if (recording.transcriptionStatus == TranscriptionStatus.completed || 
                (recording.transcript?.isNotEmpty ?? false)) {
              // Navigate to transcription screen
              print('Navigating to transcription screen');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TranscriptionScreen(recording: recording),
                ),
              );
            } else if (recording.transcriptionStatus == TranscriptionStatus.failed) {
              // Retry transcription
              print('Retrying transcription');
              context.read<RecordingBloc>().add(
                StartTranscriptionRequested(recording.id),
              );
            } else if (recording.transcriptionStatus == TranscriptionStatus.notStarted) {
              // Start transcription
              print('Starting transcription');
              context.read<RecordingBloc>().add(
                StartTranscriptionRequested(recording.id),
              );
            } else {
              print('Transcription button pressed but no action taken. Status: ${recording.transcriptionStatus}');
            }
          },
          isLoading: isTranscribing,
        );
      },
    );
  }

  Widget _buildTranscriptionStatusIndicator(BuildContext context) {
    switch (recording.transcriptionStatus) {
      case TranscriptionStatus.pending:
        return Icon(
          Icons.schedule,
          size: 16,
          color: Colors.orange,
        );
      case TranscriptionStatus.processing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      case TranscriptionStatus.completed:
        return Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.green,
        );
      case TranscriptionStatus.failed:
        return Icon(
          Icons.error,
          size: 16,
          color: Theme.of(context).colorScheme.error,
        );
      case TranscriptionStatus.notStarted:
        return const SizedBox.shrink();
    }
  }

  String _getTranscriptionStatusText(TranscriptionStatus status) {
    switch (status) {
      case TranscriptionStatus.pending:
        return 'Transcription pending';
      case TranscriptionStatus.processing:
        return 'Transcribing...';
      case TranscriptionStatus.completed:
        return 'Transcription ready';
      case TranscriptionStatus.failed:
        return 'Transcription failed';
      case TranscriptionStatus.notStarted:
        return '';
    }
  }

  Color _getTranscriptionStatusColor(TranscriptionStatus status, BuildContext context) {
    switch (status) {
      case TranscriptionStatus.pending:
        return Colors.orange;
      case TranscriptionStatus.processing:
        return Theme.of(context).colorScheme.primary;
      case TranscriptionStatus.completed:
        return Colors.green;
      case TranscriptionStatus.failed:
        return Theme.of(context).colorScheme.error;
      case TranscriptionStatus.notStarted:
        return Colors.grey;
    }
  }
}
