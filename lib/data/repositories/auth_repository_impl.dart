import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;
  
  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firestore,
  });
  
  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final firebase_auth.UserCredential userCredential = 
          await firebaseAuth.signInWithCredential(credential);
      
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        return Left(AuthFailure('Failed to sign in with Google'));
      }

      // Create User entity
      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        preferences: UserPreferences(
          name: 'AI Assistant',
          role: 'lecture assistant',
          summaryStyle: 'concise',
          autoTranscribe: true,
          autoSummarize: true,
          language: 'en',
        ),
      );

      // Save user data to Firestore
      await firestore.collection('users').doc(firebaseUser.uid).set({
        'id': user.id,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'preferences': {
          'name': user.preferences.name,
          'role': user.preferences.role,
          'summaryStyle': user.preferences.summaryStyle,
          'autoTranscribe': user.preferences.autoTranscribe,
          'autoSummarize': user.preferences.autoSummarize,
          'language': user.preferences.language,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Google Sign-In failed: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const Right(null);
      }
      
      // Временно используем только Firebase Auth данные
      // TODO: Включить Firestore после настройки правил
      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        preferences: UserPreferences(
          name: firebaseUser.displayName ?? 'AI Assistant',
          role: 'lecture assistant',
          summaryStyle: 'concise',
          autoTranscribe: true,
          autoSummarize: true,
          language: 'en',
        ),
      );
      
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Failed to get current user: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, bool>> isSignedIn() async {
    try {
      return Right(firebaseAuth.currentUser != null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateUserPreferences(UserPreferences preferences) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure('No authenticated user'));
      }

      await firestore.collection('users').doc(currentUser.uid).update({
        'preferences': {
          'name': preferences.name,
          'role': preferences.role,
          'summaryStyle': preferences.summaryStyle,
          'autoTranscribe': preferences.autoTranscribe,
          'autoSummarize': preferences.autoSummarize,
          'language': preferences.language,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Failed to update user preferences: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> getCurrentUserPreferences() async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure('No authenticated user'));
      }

      final doc = await firestore.collection('users').doc(currentUser.uid).get();
      if (!doc.exists) {
        return Left(AuthFailure('User document not found'));
      }

      final data = doc.data()!;
      final preferencesData = data['preferences'] as Map<String, dynamic>?;
      
      if (preferencesData == null) {
        return Left(AuthFailure('User preferences not found'));
      }

      final preferences = UserPreferences(
        name: preferencesData['name'] ?? 'AI Assistant',
        role: preferencesData['role'] ?? 'lecture assistant',
        summaryStyle: preferencesData['summaryStyle'] ?? 'concise',
        autoTranscribe: preferencesData['autoTranscribe'] ?? true,
        autoSummarize: preferencesData['autoSummarize'] ?? true,
        language: preferencesData['language'] ?? 'en',
      );

      return Right(preferences);
    } catch (e) {
      return Left(AuthFailure('Failed to get user preferences: ${e.toString()}'));
    }
  }
}
