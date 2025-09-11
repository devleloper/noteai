import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'core/utils/service_locator.dart' as di;
import 'presentation/features/home/view/home_screen.dart';
import 'presentation/features/auth/view/login_screen.dart';
import 'presentation/features/auth/bloc/auth_bloc.dart';
import 'presentation/features/auth/bloc/auth_event.dart';
import 'presentation/features/auth/bloc/auth_state.dart';
import 'presentation/features/recording/bloc/recording_bloc.dart';
import 'presentation/theme/app_theme.dart';
import 'domain/usecases/chat/create_session.dart';
import 'domain/usecases/chat/generate_summary.dart';

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
  
  // Initialize GoogleSignIn
  await GoogleSignIn.instance.initialize(
    // serverClientId will be read from google-services.json automatically
  );
  
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
            getCurrentUser: di.sl(),
            firebaseAuth: di.sl(),
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<RecordingBloc>(
          create: (context) => RecordingBloc(
            startRecording: di.sl(),
            stopRecording: di.sl(),
            getRecordings: di.sl(),
            deleteRecording: di.sl(),
            startTranscription: di.sl(),
            updateTranscription: di.sl(),
            createSession: di.sl<CreateSession>(),
            generateSummary: di.sl<GenerateSummary>(),
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
        } else if (state is AuthError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthCheckRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
