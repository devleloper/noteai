import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/recording_bloc.dart';
import '../bloc/recording_event.dart';
import '../bloc/recording_state.dart';
import '../widgets/animated_circle.dart';

class StealthRecordingScreen extends StatefulWidget {
  const StealthRecordingScreen({super.key});

  @override
  State<StealthRecordingScreen> createState() => _StealthRecordingScreenState();
}

class _StealthRecordingScreenState extends State<StealthRecordingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade in animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Start fade in animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleStealthModeStop() {
    context.read<RecordingBloc>().add(const StealthRecordingStopped());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state is RecordingCompleted) {
            // Navigate back to home screen and start automatic transcription
            Navigator.of(context).pop();
            // Automatic transcription will start in the background via RecordingBloc
          } else if (state is RecordingError) {
            // Show error and navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated circle
                      AnimatedCircle(
                        onLongPress: _handleStealthModeStop,
                        isActive: state is StealthActive,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
