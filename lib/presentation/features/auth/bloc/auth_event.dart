import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInWithGoogleRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final String? userId;
  
  const AuthUserChanged(this.userId);
  
  @override
  List<Object> get props => [userId ?? ''];
}

class AuthRefreshUserRequested extends AuthEvent {
  const AuthRefreshUserRequested();
}
