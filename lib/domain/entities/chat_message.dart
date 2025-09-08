import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String recordingId;
  final String content;
  final ChatMessageRole role;
  final DateTime createdAt;
  final bool isSynced;
  
  const ChatMessage({
    required this.id,
    required this.recordingId,
    required this.content,
    required this.role,
    required this.createdAt,
    required this.isSynced,
  });
  
  @override
  List<Object> get props => [
    id,
    recordingId,
    content,
    role,
    createdAt,
    isSynced,
  ];
  
  ChatMessage copyWith({
    String? id,
    String? recordingId,
    String? content,
    ChatMessageRole? role,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      content: content ?? this.content,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

enum ChatMessageRole {
  user,
  assistant,
  system,
}
