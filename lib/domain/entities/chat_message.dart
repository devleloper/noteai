import 'package:equatable/equatable.dart';

enum MessageType {
  user,
  ai,
  system,
}

class ChatMessage extends Equatable {
  final String id;
  final String sessionId;
  final MessageType type;
  final String content;
  final String? model; // AI model used for generation
  final DateTime timestamp;
  final String? parentMessageId; // For replies
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.content,
    this.model,
    required this.timestamp,
    this.parentMessageId,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        type,
        content,
        model,
        timestamp,
        parentMessageId,
        metadata,
      ];

  ChatMessage copyWith({
    String? id,
    String? sessionId,
    MessageType? type,
    String? content,
    String? model,
    DateTime? timestamp,
    String? parentMessageId,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      content: content ?? this.content,
      model: model ?? this.model,
      timestamp: timestamp ?? this.timestamp,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      metadata: metadata ?? this.metadata,
    );
  }
}