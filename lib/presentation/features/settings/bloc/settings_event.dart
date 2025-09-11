import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateLanguageRequested extends SettingsEvent {
  final String languageCode;

  const UpdateLanguageRequested(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}

class LoadUserPreferences extends SettingsEvent {
  const LoadUserPreferences();
}
