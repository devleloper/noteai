import 'package:equatable/equatable.dart';
import '../../../../domain/entities/user.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserPreferences preferences;

  const SettingsLoaded({required this.preferences});

  @override
  List<Object> get props => [preferences];
}

class SettingsUpdating extends SettingsState {
  final UserPreferences preferences;

  const SettingsUpdating({required this.preferences});

  @override
  List<Object> get props => [preferences];
}

class SettingsUpdated extends SettingsState {
  final UserPreferences preferences;
  final String message;

  const SettingsUpdated({
    required this.preferences,
    required this.message,
  });

  @override
  List<Object> get props => [preferences, message];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}
