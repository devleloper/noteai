import 'package:flutter/material.dart';
import '../../../../domain/entities/recording.dart';

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
                      // TODO: Implement play functionality
                    },
                  ),
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
                    icon: Icons.share,
                    label: 'Share',
                    onPressed: () {
                      // TODO: Implement share functionality
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
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
}
