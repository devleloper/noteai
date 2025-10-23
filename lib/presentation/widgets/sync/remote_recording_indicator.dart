import 'package:flutter/material.dart';
import '../../../data/models/sync/sync_models.dart';

/// Widget for displaying remote recording information
class RemoteRecordingIndicator extends StatelessWidget {
  final String deviceId;
  final String? deviceName;
  final VoidCallback? onTap;
  final bool showDetails;

  const RemoteRecordingIndicator({
    super.key,
    required this.deviceId,
    this.deviceName,
    this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.devices_other,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Recorded on another device',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (showDetails && deviceName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Device: $deviceName',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.info_outline,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version for use in lists
class CompactRemoteRecordingIndicator extends StatelessWidget {
  final String deviceId;
  final String? deviceName;

  const CompactRemoteRecordingIndicator({
    super.key,
    required this.deviceId,
    this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.devices_other,
            color: colorScheme.primary,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'Remote',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying audio download status
class AudioDownloadStatus extends StatelessWidget {
  final bool isDownloading;
  final bool isDownloaded;
  final VoidCallback? onDownload;
  final VoidCallback? onPlay;

  const AudioDownloadStatus({
    super.key,
    this.isDownloading = false,
    this.isDownloaded = false,
    this.onDownload,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isDownloading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Downloading...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    if (isDownloaded) {
      return GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow,
                color: colorScheme.onSecondaryContainer,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Play',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onDownload,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download,
              color: colorScheme.onTertiaryContainer,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Download',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
