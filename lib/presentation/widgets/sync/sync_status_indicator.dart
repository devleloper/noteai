import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/sync/sync_models.dart';
import '../../../../core/services/sync/cross_device_sync_service.dart';

/// Widget for displaying sync status indicator
class SyncStatusIndicator extends StatefulWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const SyncStatusIndicator({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
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
    return StreamBuilder<SyncStatus>(
      stream: _getSyncStatusStream(),
      builder: (context, snapshot) {
        final syncStatus = snapshot.data;
        if (syncStatus == null) {
          return const SizedBox.shrink();
        }

        return _buildStatusIndicator(syncStatus);
      },
    );
  }

  Widget _buildStatusIndicator(SyncStatus syncStatus) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (syncStatus.state) {
      case SyncState.idle:
        return _buildIdleIndicator(theme, colorScheme);
      case SyncState.syncing:
        return _buildSyncingIndicator(theme, colorScheme, syncStatus);
      case SyncState.error:
        return _buildErrorIndicator(theme, colorScheme, syncStatus.error);
      case SyncState.offline:
        return _buildOfflineIndicator(theme, colorScheme);
      case SyncState.conflict:
        return _buildConflictIndicator(theme, colorScheme);
    }
  }

  Widget _buildIdleIndicator(ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_done,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Synced',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncingIndicator(ThemeData theme, ColorScheme colorScheme, SyncStatus syncStatus) {
    _animationController.repeat();

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Icon(
                    Icons.sync,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            Text(
              'Syncing...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            if (widget.showDetails && syncStatus.pendingOperations > 0) ...[
              const SizedBox(width: 4),
              Text(
                '(${syncStatus.pendingOperations})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIndicator(ThemeData theme, ColorScheme colorScheme, String? error) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 4),
            Text(
              'Sync Error',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
            if (widget.showDetails && error != null) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: error,
                child: Icon(
                  Icons.info_outline,
                  size: 14,
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineIndicator(ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Offline',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictIndicator(ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_outlined,
              size: 16,
              color: colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              'Conflict',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<SyncStatus> _getSyncStatusStream() {
    // TODO: Implement actual sync status stream
    // For now, return a mock stream
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) => const SyncStatus(
        id: 'sync',
        state: SyncState.idle,
        lastSync: null,
        pendingOperations: 0,
      ),
    );
  }
}

/// Compact sync status indicator for app bars
class CompactSyncStatusIndicator extends StatelessWidget {
  final VoidCallback? onTap;

  const CompactSyncStatusIndicator({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: _getSyncStatusStream(),
      builder: (context, snapshot) {
        final syncStatus = snapshot.data;
        if (syncStatus == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(context, syncStatus.state),
            ),
            child: Icon(
              _getStatusIcon(syncStatus.state),
              size: 16,
              color: _getStatusIconColor(context, syncStatus.state),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(BuildContext context, SyncState state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (state) {
      case SyncState.idle:
        return colorScheme.primary;
      case SyncState.syncing:
        return colorScheme.primaryContainer;
      case SyncState.error:
        return colorScheme.errorContainer;
      case SyncState.offline:
        return colorScheme.surfaceVariant;
      case SyncState.conflict:
        return colorScheme.tertiaryContainer;
    }
  }

  IconData _getStatusIcon(SyncState state) {
    switch (state) {
      case SyncState.idle:
        return Icons.cloud_done;
      case SyncState.syncing:
        return Icons.sync;
      case SyncState.error:
        return Icons.error_outline;
      case SyncState.offline:
        return Icons.cloud_off;
      case SyncState.conflict:
        return Icons.warning_outlined;
    }
  }

  Color _getStatusIconColor(BuildContext context, SyncState state) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (state) {
      case SyncState.idle:
        return colorScheme.onPrimary;
      case SyncState.syncing:
        return colorScheme.onPrimaryContainer;
      case SyncState.error:
        return colorScheme.onErrorContainer;
      case SyncState.offline:
        return colorScheme.onSurfaceVariant;
      case SyncState.conflict:
        return colorScheme.onTertiaryContainer;
    }
  }

  Stream<SyncStatus> _getSyncStatusStream() {
    // TODO: Implement actual sync status stream
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) => const SyncStatus(
        id: 'sync',
        state: SyncState.idle,
        lastSync: null,
        pendingOperations: 0,
      ),
    );
  }
}
