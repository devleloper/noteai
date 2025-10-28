import 'package:flutter/material.dart';

class SummarizationProgressIndicator extends StatefulWidget {
  final String message;
  final double? progress; // 0.0 to 1.0, null for indeterminate
  final Duration? estimatedTimeRemaining;
  final VoidCallback? onCancel;
  final int retryAttempts;

  const SummarizationProgressIndicator({
    super.key,
    this.message = 'Summarizing your recording...',
    this.progress,
    this.estimatedTimeRemaining,
    this.onCancel,
    this.retryAttempts = 0,
  });

  @override
  State<SummarizationProgressIndicator> createState() => _SummarizationProgressIndicatorState();
}

class _SummarizationProgressIndicatorState extends State<SummarizationProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for indeterminate progress
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Progress animation for determinate progress
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress ?? 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    if (widget.progress == null) {
      _pulseController.repeat(reverse: true);
    } else {
      _progressController.forward();
    }
  }

  @override
  void didUpdateWidget(SummarizationProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.progress != oldWidget.progress) {
      if (widget.progress == null) {
        _pulseController.repeat(reverse: true);
        _progressController.stop();
      } else {
        _pulseController.stop();
        _progressController.animateTo(widget.progress!);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with message and cancel button
          Row(
            children: [
              // Progress indicator icon
              SizedBox(
                width: 24,
                height: 24,
                child: widget.progress == null
                    ? AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: IndeterminateProgressPainter(_pulseAnimation.value),
                          );
                        },
                      )
                    : AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: DeterminateProgressPainter(_progressAnimation.value),
                          );
                        },
                      ),
              ),
              const SizedBox(width: 12),
              
              // Message
              Expanded(
                child: Text(
                  widget.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              
              // Cancel button
              if (widget.onCancel != null)
                IconButton(
                  onPressed: widget.onCancel,
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    size: 18,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          if (widget.progress != null) ...[
            LinearProgressIndicator(
              value: widget.progress,
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Additional info row
          Row(
            children: [
              // Retry attempts
              if (widget.retryAttempts > 0) ...[
                Icon(
                  Icons.refresh,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'Attempt ${widget.retryAttempts + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              
              // Estimated time remaining
              if (widget.estimatedTimeRemaining != null) ...[
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(widget.estimatedTimeRemaining!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s remaining';
    } else {
      return '${duration.inSeconds}s remaining';
    }
  }
}

class IndeterminateProgressPainter extends CustomPainter {
  final double animationValue;

  IndeterminateProgressPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 3.0;

    // Draw three dots with animation
    for (int i = 0; i < 3; i++) {
      final offset = Offset(
        center.dx - 6 + (i * 6),
        center.dy,
      );
      
      // Animate opacity and scale
      final delay = i * 0.2;
      final animatedValue = (animationValue - delay).clamp(0.0, 1.0);
      final opacity = (animatedValue * 2 - 1).abs();
      final scale = 0.5 + (opacity * 0.5);
      
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.scale(scale);
      paint.color = Colors.blue.withOpacity(opacity);
      canvas.drawCircle(Offset.zero, radius, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DeterminateProgressPainter extends CustomPainter {
  final double progress;

  DeterminateProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 8.0;

    // Background circle
    paint.color = Colors.grey.withOpacity(0.3);
    canvas.drawCircle(center, radius, paint);

    // Progress arc
    paint.color = Colors.blue;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    paint.strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
