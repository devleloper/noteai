import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'core/utils/service_locator.dart' as di;
import 'presentation/features/home/view/home_screen.dart';
import 'presentation/features/auth/view/login_screen.dart';
import 'presentation/features/auth/bloc/auth_bloc.dart';
import 'presentation/features/auth/bloc/auth_event.dart';
import 'presentation/features/auth/bloc/auth_state.dart';
import 'presentation/features/recording/bloc/recording_bloc.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const NoteAIApp());
}

class NoteAIApp extends StatelessWidget {
  const NoteAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            signInWithGoogle: di.sl(),
            firebaseAuth: di.sl(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<RecordingBloc>(
          create: (context) => RecordingBloc(
            startRecording: di.sl(),
            stopRecording: di.sl(),
            getRecordings: di.sl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'NoteAI',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is AuthAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
