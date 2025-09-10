import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../domain/usecases/auth/sign_in_with_google.dart';
import '../../../../domain/usecases/auth/get_current_user.dart';
import '../../../../domain/usecases/usecase.dart';
import '../../../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final GetCurrentUser _getCurrentUser;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  
  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required GetCurrentUser getCurrentUser,
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _signInWithGoogle = signInWithGoogle,
       _getCurrentUser = getCurrentUser,
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
      // User is already signed in, get real user data
      final result = await _getCurrentUser(NoParams());
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (userData) {
          if (userData != null) {
            emit(AuthAuthenticated(userData));
          } else {
            emit(AuthUnauthenticated());
          }
        },
      );
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
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Clear sensitive data from local storage
      // Note: Local recordings are preserved as per requirements
      // Only authentication tokens and user data are cleared
      
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
      // User is signed in, get real user data
      emit(AuthLoading());
      
      final result = await _getCurrentUser(NoParams());
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (userData) {
          if (userData != null) {
            emit(AuthAuthenticated(userData));
          } else {
            emit(AuthUnauthenticated());
          }
        },
      );
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
