import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/recording.dart';
import '../../recording/bloc/recording_bloc.dart';
import '../../recording/bloc/recording_state.dart';
import '../../recording/bloc/recording_event.dart';

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
      ),
      body: BlocBuilder<RecordingBloc, RecordingState>(
        builder: (context, state) {
          // Get the most up-to-date recording from the current state
          Recording currentRecording = recording;
          
          if (state is RecordingsLoaded) {
            final updatedRecording = state.recordings.firstWhere(
              (r) => r.id == recording.id,
              orElse: () => recording,
            );
            currentRecording = updatedRecording;
          } else if (state is TranscriptionProcessing) {
            final updatedRecording = state.recordings.firstWhere(
              (r) => r.id == recording.id,
              orElse: () => recording,
            );
            currentRecording = updatedRecording;
          } else if (state is TranscriptionCompleted) {
            // If transcription just completed, we need to reload recordings
            context.read<RecordingBloc>().add(LoadRecordingsRequested());
          }
          
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recording metadata
                  _buildMetadataCard(context, currentRecording),
                  
                  const SizedBox(height: 16),
                  
                  // Transcription content
                  Expanded(
                    child: _buildTranscriptionContent(context, currentRecording),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetadataCard(BuildContext context, Recording currentRecording) {
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
              _formatDuration(currentRecording.duration),
              Icons.timer,
            ),
            _buildMetadataRow(
              context,
              'Created',
              _formatDateTime(currentRecording.createdAt),
              Icons.calendar_today,
            ),
            if (currentRecording.transcriptionCompletedAt != null)
              _buildMetadataRow(
                context,
                'Transcribed',
                _formatDateTime(currentRecording.transcriptionCompletedAt!),
                Icons.text_snippet,
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

  Widget _buildTranscriptionContent(BuildContext context, Recording currentRecording) {
    if (currentRecording.transcriptionStatus == TranscriptionStatus.failed) {
      return _buildErrorState(context, currentRecording);
    }

    if (currentRecording.transcriptionStatus == TranscriptionStatus.processing ||
        currentRecording.transcriptionStatus == TranscriptionStatus.pending) {
      return _buildLoadingState(context);
    }

    if (currentRecording.transcript == null || currentRecording.transcript!.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildTranscriptionText(context, currentRecording);
  }

  Widget _buildErrorState(BuildContext context, Recording currentRecording) {
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
            currentRecording.transcriptionError ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Retry transcription
              context.read<RecordingBloc>().add(
                StartTranscriptionRequested(currentRecording.id),
              );
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

  Widget _buildTranscriptionText(BuildContext context, Recording currentRecording) {
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
                  onPressed: () => _copyToClipboard(context, currentRecording),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SelectableText(
                currentRecording.transcript!,
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

  void _copyToClipboard(BuildContext context, Recording currentRecording) {
    if (currentRecording.transcript != null && currentRecording.transcript!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: currentRecording.transcript!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transcription copied to clipboard'),
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

}

