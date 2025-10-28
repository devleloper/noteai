import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/recording.dart';
import '../../player/widgets/mini_player_widget.dart';
import '../../recording/bloc/recording_bloc.dart';
import '../../recording/bloc/recording_state.dart';
import '../../recording/bloc/recording_event.dart';
import '../../transcription/view/transcription_screen.dart';
import '../../chat/view/chat_screen.dart';
import 'rename_dialog.dart';
import '../../../widgets/sync/remote_recording_indicator.dart';

class RecordingCard extends StatefulWidget {
  final Recording recording;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<String>? onRename;

  const RecordingCard({
    super.key,
    required this.recording,
    required this.onTap,
    required this.onDelete,
    this.onRename,
  });

  @override
  State<RecordingCard> createState() => _RecordingCardState();
}

class _RecordingCardState extends State<RecordingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging to track state updates
    print('RecordingCard building for recording: ${widget.recording.id}');
    print('Transcription status: ${widget.recording.transcriptionStatus}');
    print('Has transcript: ${widget.recording.transcript?.isNotEmpty ?? false}');
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: widget.onTap,
              onLongPress: widget.onRename != null ? () => _showRenameDialog(context) : null,
              onLongPressStart: (_) => _animationController.forward(),
              onLongPressEnd: (_) => _animationController.reverse(),
              onLongPressCancel: () => _animationController.reverse(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      widget.recording.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDuration(widget.recording.duration),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              // Remote recording indicator
              if (widget.recording.isRemote) ...[
                const SizedBox(height: 8),
                CompactRemoteRecordingIndicator(
                  deviceId: widget.recording.deviceId ?? 'Unknown Device',
                  deviceName: _getDeviceName(widget.recording.deviceId),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Status and progress
              Row(
                children: [
                  Icon(
                    _getStatusIcon(widget.recording.status),
                    size: 16,
                    color: _getStatusColor(widget.recording.status, context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusText(widget.recording.status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(widget.recording.status, context),
                    ),
                  ),
                  if (widget.recording.progress < 1.0 && widget.recording.status == RecordingStatus.processing) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: widget.recording.progress,
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
              if (widget.recording.transcriptionStatus != TranscriptionStatus.notStarted) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTranscriptionStatusIndicator(context),
                    const SizedBox(width: 4),
                    Text(
                      _getTranscriptionStatusText(widget.recording.transcriptionStatus),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getTranscriptionStatusColor(widget.recording.transcriptionStatus, context),
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
                          recording: widget.recording,
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(recordingId: widget.recording.id),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    context: context,
                    icon: Icons.delete,
                    label: 'Delete',
                    onPressed: widget.onDelete,
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
        ),
      );
    });
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
        if (state is TranscriptionProcessing && state.recordingId == widget.recording.id) {
          isTranscribing = true;
        }

        return _buildActionButton(
          context: context,
          icon: isTranscribing ? Icons.sync : Icons.text_snippet,
          label: isTranscribing ? 'Transcribing' : 'Transcribe',
          onPressed: () {
            print('Transcription button pressed for recording: ${widget.recording.id}');
            print('Current transcription status: ${widget.recording.transcriptionStatus}');
            print('Has transcript: ${widget.recording.transcript?.isNotEmpty ?? false}');
            print('Transcript length: ${widget.recording.transcript?.length ?? 0}');
            
            // Check for completed transcription or existing transcript
            if (widget.recording.transcriptionStatus == TranscriptionStatus.completed || 
                (widget.recording.transcript?.isNotEmpty ?? false)) {
              // Navigate to transcription screen
              print('Navigating to transcription screen');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TranscriptionScreen(recording: widget.recording),
                ),
              );
            } else if (widget.recording.transcriptionStatus == TranscriptionStatus.failed) {
              // Retry transcription
              print('Retrying transcription');
              context.read<RecordingBloc>().add(
                StartTranscriptionRequested(widget.recording.id),
              );
            } else if (widget.recording.transcriptionStatus == TranscriptionStatus.notStarted) {
              // Start transcription
              print('Starting transcription');
              context.read<RecordingBloc>().add(
                StartTranscriptionRequested(widget.recording.id),
              );
            } else {
              print('Transcription button pressed but no action taken. Status: ${widget.recording.transcriptionStatus}');
            }
          },
          isLoading: isTranscribing,
        );
      },
    );
  }

  Widget _buildTranscriptionStatusIndicator(BuildContext context) {
    switch (widget.recording.transcriptionStatus) {
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

  void _showRenameDialog(BuildContext context) {
    // Provide haptic feedback
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        currentTitle: widget.recording.title,
        onSave: (newTitle) {
          widget.onRename?.call(newTitle);
        },
      ),
    );
  }

  String _getDeviceName(String? deviceId) {
    if (deviceId == null) return 'Unknown Device';
    
    // Simple device name mapping - in a real app, this would come from device registry
    if (deviceId.contains('iPhone')) return 'iPhone';
    if (deviceId.contains('iPad')) return 'iPad';
    if (deviceId.contains('Android')) return 'Android';
    if (deviceId.contains('Mac')) return 'Mac';
    if (deviceId.contains('Windows')) return 'Windows';
    
    return 'Device ${deviceId.substring(0, 8)}...';
  }
}
