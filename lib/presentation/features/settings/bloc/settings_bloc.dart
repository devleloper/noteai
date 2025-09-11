import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/auth/get_user_preferences.dart';
import '../../../../domain/usecases/auth/update_user_preferences.dart';
import '../../../../domain/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetUserPreferences _getUserPreferences;
  final UpdateUserPreferences _updateUserPreferences;

  SettingsBloc({
    required GetUserPreferences getUserPreferences,
    required UpdateUserPreferences updateUserPreferences,
  }) : _getUserPreferences = getUserPreferences,
       _updateUserPreferences = updateUserPreferences,
       super(SettingsInitial()) {
    
    on<LoadUserPreferences>(_onLoadUserPreferences);
    on<UpdateLanguageRequested>(_onUpdateLanguageRequested);
  }

  Future<void> _onLoadUserPreferences(
    LoadUserPreferences event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    final result = await _getUserPreferences(NoParams());
    
    result.fold(
      (failure) => emit(SettingsError(_mapFailureToMessage(failure))),
      (preferences) => emit(SettingsLoaded(preferences: preferences)),
    );
  }

  Future<void> _onUpdateLanguageRequested(
    UpdateLanguageRequested event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is! SettingsLoaded) return;

    final currentState = state as SettingsLoaded;
    emit(SettingsUpdating(preferences: currentState.preferences));

    // Create updated preferences with new language
    final updatedPreferences = UserPreferences(
      name: currentState.preferences.name,
      role: currentState.preferences.role,
      summaryStyle: currentState.preferences.summaryStyle,
      autoTranscribe: currentState.preferences.autoTranscribe,
      autoSummarize: currentState.preferences.autoSummarize,
      language: event.languageCode,
    );

    final result = await _updateUserPreferences(
      UpdateUserPreferencesParams(preferences: updatedPreferences),
    );

    result.fold(
      (failure) => emit(SettingsError(_mapFailureToMessage(failure))),
      (_) {
        emit(SettingsUpdated(
          preferences: updatedPreferences,
          message: 'Language updated successfully',
        ));
        
        // Return to loaded state to allow further updates
        emit(SettingsLoaded(preferences: updatedPreferences));
        
        // Notify AuthBloc to refresh user data
        // This will be handled by the parent widget
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure:
        return 'Authentication error: ${failure.message}';
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      case ServerFailure:
        return 'Server error: ${failure.message}';
      default:
        return 'An unexpected error occurred: ${failure.message}';
    }
  }
}
