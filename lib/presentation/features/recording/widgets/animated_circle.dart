import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedCircle extends StatefulWidget {
  final VoidCallback? onLongPress;
  final bool isActive;
  
  const AnimatedCircle({
    super.key,
    this.onLongPress,
    this.isActive = true,
  });

  @override
  State<AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _scaleController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Breathing animation controller (2 second cycle)
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Scale animation controller for long-press feedback
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Breathing animation: scale from 0.8 to 1.2
    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // Scale animation for long-press feedback
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Start breathing animation if active
    if (widget.isActive) {
      _breathingController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isActive && !oldWidget.isActive) {
      _breathingController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _breathingController.stop();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleLongPressStart() {
    HapticFeedback.lightImpact();
    _scaleController.forward();
  }

  void _handleLongPressEnd() {
    HapticFeedback.mediumImpact();
    _scaleController.reverse();
    widget.onLongPress?.call();
  }

  void _handleLongPressCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _handleLongPressStart(),
      onLongPressEnd: (_) => _handleLongPressEnd(),
      onLongPressCancel: _handleLongPressCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathingAnimation, _scaleAnimation]),
        builder: (context, child) {
          final breathingScale = widget.isActive ? _breathingAnimation.value : 1.0;
          final pressScale = _scaleAnimation.value;
          final finalScale = breathingScale * pressScale;
          
          return Transform.scale(
            scale: finalScale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
