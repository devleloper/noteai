import 'package:flutter/material.dart';

class SummarizationLoadingWidget extends StatefulWidget {
  final String message;
  final int retryAttempts;

  const SummarizationLoadingWidget({
    Key? key,
    this.message = 'Summarizing your recording...',
    this.retryAttempts = 0,
  }) : super(key: key);

  @override
  State<SummarizationLoadingWidget> createState() => _SummarizationLoadingWidgetState();
}

class _SummarizationLoadingWidgetState extends State<SummarizationLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Animated dots
          SizedBox(
            width: 24,
            height: 24,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: DotPainter(_animation.value),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (widget.retryAttempts > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Retry attempt ${widget.retryAttempts}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DotPainter extends CustomPainter {
  final double animationValue;

  DotPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
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
