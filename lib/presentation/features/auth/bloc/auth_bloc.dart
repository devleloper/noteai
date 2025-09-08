import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../domain/usecases/auth/sign_in_with_google.dart';
import '../../../../domain/usecases/usecase.dart';
import '../../../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  
  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _signInWithGoogle = signInWithGoogle,
       _firebaseAuth = firebaseAuth,
       super(AuthInitial()) {
    
    // Listen to Firebase Auth state changes
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? user) {
      add(AuthUserChanged(user?.uid));
    });
    
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onUserChanged);
  }
  
  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // User is already signed in, emit authenticated state
      final tempUser = User(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        preferences: const UserPreferences(
          name: 'AI Assistant',
          role: 'lecture assistant',
          summaryStyle: 'concise',
          autoTranscribe: true,
          autoSummarize: true,
          language: 'en',
        ),
      );
      emit(AuthAuthenticated(tempUser));
    } else {
      emit(AuthUnauthenticated());
    }
  }
  
  void _onSignInWithGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _signInWithGoogle(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
  
  void _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await _firebaseAuth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.userId != null) {
      // User is signed in, emit authenticated state
      emit(AuthLoading());
      
      // Get current Firebase user
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final tempUser = User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          preferences: const UserPreferences(
            name: 'AI Assistant',
            role: 'lecture assistant',
            summaryStyle: 'concise',
            autoTranscribe: true,
            autoSummarize: true,
            language: 'en',
          ),
        );
        emit(AuthAuthenticated(tempUser));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
