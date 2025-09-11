import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/recording.dart';

class TranscriptionScreen extends StatelessWidget {
  final Recording recording;

  const TranscriptionScreen({
    super.key,
    required this.recording,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recording.title),
        actions: [
          if (recording.transcript != null && recording.transcript!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyToClipboard(context),
              tooltip: 'Copy to clipboard',
            ),
          if (recording.transcript != null && recording.transcript!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareTranscription(context),
              tooltip: 'Share transcription',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recording metadata
              _buildMetadataCard(context),
              
              const SizedBox(height: 16),
              
              // Transcription content
              Expanded(
                child: _buildTranscriptionContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recording Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMetadataRow(
              context,
              'Duration',
              _formatDuration(recording.duration),
              Icons.timer,
            ),
            _buildMetadataRow(
              context,
              'Created',
              _formatDateTime(recording.createdAt),
              Icons.calendar_today,
            ),
            if (recording.transcriptionCompletedAt != null)
              _buildMetadataRow(
                context,
                'Transcribed',
                _formatDateTime(recording.transcriptionCompletedAt!),
                Icons.text_snippet,
              ),
            _buildMetadataRow(
              context,
              'Status',
              _getTranscriptionStatusText(recording.transcriptionStatus),
              _getTranscriptionStatusIcon(recording.transcriptionStatus),
              statusColor: _getTranscriptionStatusColor(recording.transcriptionStatus, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: statusColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionContent(BuildContext context) {
    if (recording.transcriptionStatus == TranscriptionStatus.failed) {
      return _buildErrorState(context);
    }

    if (recording.transcriptionStatus == TranscriptionStatus.processing ||
        recording.transcriptionStatus == TranscriptionStatus.pending) {
      return _buildLoadingState(context);
    }

    if (recording.transcript == null || recording.transcript!.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildTranscriptionText(context);
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Transcription Failed',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recording.transcriptionError ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement retry functionality
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Transcribing audio...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.text_snippet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transcription Available',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Transcription has not been generated for this recording yet.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionText(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.text_snippet,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transcription',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SelectableText(
                recording.transcript!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    if (recording.transcript != null && recording.transcript!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: recording.transcript!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transcription copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareTranscription(BuildContext context) {
    if (recording.transcript != null && recording.transcript!.isNotEmpty) {
      // TODO: Implement sharing functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sharing functionality coming soon'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (hours > 0) {
      return '${twoDigits(hours)}:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getTranscriptionStatusText(TranscriptionStatus status) {
    switch (status) {
      case TranscriptionStatus.notStarted:
        return 'Not started';
      case TranscriptionStatus.pending:
        return 'Pending';
      case TranscriptionStatus.processing:
        return 'Processing';
      case TranscriptionStatus.completed:
        return 'Completed';
      case TranscriptionStatus.failed:
        return 'Failed';
    }
  }

  IconData _getTranscriptionStatusIcon(TranscriptionStatus status) {
    switch (status) {
      case TranscriptionStatus.notStarted:
        return Icons.radio_button_unchecked;
      case TranscriptionStatus.pending:
        return Icons.schedule;
      case TranscriptionStatus.processing:
        return Icons.sync;
      case TranscriptionStatus.completed:
        return Icons.check_circle;
      case TranscriptionStatus.failed:
        return Icons.error;
    }
  }

  Color _getTranscriptionStatusColor(TranscriptionStatus status, BuildContext context) {
    switch (status) {
      case TranscriptionStatus.notStarted:
        return Colors.grey;
      case TranscriptionStatus.pending:
        return Colors.orange;
      case TranscriptionStatus.processing:
        return Theme.of(context).colorScheme.primary;
      case TranscriptionStatus.completed:
        return Colors.green;
      case TranscriptionStatus.failed:
        return Theme.of(context).colorScheme.error;
    }
  }
}

