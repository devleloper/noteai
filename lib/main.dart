import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'core/utils/service_locator.dart' as di;
import 'core/services/sync/cross_device_sync_service.dart';
import 'core/services/sync/firestore_sync_manager.dart';
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
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    print('NoteAI: Starting app initialization...');
    
    // Initialize Firebase
    print('NoteAI: Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('NoteAI: Firebase initialized successfully');
    
    // Load environment variables
    print('NoteAI: Loading environment variables...');
    await dotenv.load(fileName: '.env');
    print('NoteAI: Environment variables loaded');
    
    // Initialize dependency injection
    print('NoteAI: Initializing dependency injection...');
    await di.init();
    print('NoteAI: Dependency injection initialized');
    
    // Initialize GoogleSignIn
    print('NoteAI: Initializing GoogleSignIn...');
    await GoogleSignIn.instance.initialize(
      // serverClientId will be read from google-services.json automatically
    );
    print('NoteAI: GoogleSignIn initialized');
    
    // Initialize CrossDeviceSyncService
    print('NoteAI: Initializing CrossDeviceSyncService...');
    final syncService = di.sl<CrossDeviceSyncService>();
    await syncService.initialize();
    print('NoteAI: CrossDeviceSyncService initialized');
    
    print('NoteAI: All services initialized successfully');
    runApp(const NoteAIApp());
  } catch (e, stackTrace) {
    print('NoteAI: Error during initialization: $e');
    print('NoteAI: Stack trace: $stackTrace');
    
    // Run app anyway with error handling
    runApp(ErrorApp(error: e.toString()));
  }
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
            updateRecording: di.sl(),
            startTranscription: di.sl(),
            updateTranscription: di.sl(),
            createSession: di.sl<CreateSession>(),
            generateSummary: di.sl<GenerateSummary>(),
            getUserPreferences: di.sl(),
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
          // Start sync services after authentication
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              final syncService = di.sl<CrossDeviceSyncService>();
              syncService.startSync();
              final firestoreSyncManager = di.sl<FirestoreSyncManager>();
              firestoreSyncManager.startListening();
            } catch (e) {
              print('Error starting sync services: $e');
            }
          });
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

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteAI - Error',
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Application Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'An error occurred during app initialization:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Reload the page
                    if (kIsWeb) {
                      // For web, reload the page
                      // ignore: avoid_web_libraries_in_flutter
                      // html.window.location.reload();
                    }
                  },
                  child: const Text('Reload App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
