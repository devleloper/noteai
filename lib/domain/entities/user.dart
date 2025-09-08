import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserPreferences preferences;
  
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    required this.preferences,
  });
  
  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    createdAt,
    lastLoginAt,
    preferences,
  ];
  
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserPreferences extends Equatable {
  final String name;
  final String role;
  final String summaryStyle;
  final bool autoTranscribe;
  final bool autoSummarize;
  final String language;
  
  const UserPreferences({
    required this.name,
    required this.role,
    required this.summaryStyle,
    required this.autoTranscribe,
    required this.autoSummarize,
    required this.language,
  });
  
  @override
  List<Object> get props => [
    name,
    role,
    summaryStyle,
    autoTranscribe,
    autoSummarize,
    language,
  ];
  
  UserPreferences copyWith({
    String? name,
    String? role,
    String? summaryStyle,
    bool? autoTranscribe,
    bool? autoSummarize,
    String? language,
  }) {
    return UserPreferences(
      name: name ?? this.name,
      role: role ?? this.role,
      summaryStyle: summaryStyle ?? this.summaryStyle,
      autoTranscribe: autoTranscribe ?? this.autoTranscribe,
      autoSummarize: autoSummarize ?? this.autoSummarize,
      language: language ?? this.language,
    );
  }
}
