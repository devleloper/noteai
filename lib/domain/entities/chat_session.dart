import 'package:equatable/equatable.dart';
import 'chat_message.dart';

class ChatSession extends Equatable {
  final String id;
  final String recordingId;
  final String? summary;
  final String defaultModel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  const ChatSession({
    required this.id,
    required this.recordingId,
    this.summary,
    required this.defaultModel,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  @override
  List<Object?> get props => [
        id,
        recordingId,
        summary,
        defaultModel,
        createdAt,
        updatedAt,
        messages,
      ];

  ChatSession copyWith({
    String? id,
    String? recordingId,
    String? summary,
    String? defaultModel,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      summary: summary ?? this.summary,
      defaultModel: defaultModel ?? this.defaultModel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  // Helper methods
  bool get hasSummary => summary != null && summary!.isNotEmpty;
  
  List<ChatMessage> get userMessages => 
      messages.where((m) => m.type == MessageType.user).toList();
  
  List<ChatMessage> get aiMessages => 
      messages.where((m) => m.type == MessageType.ai).toList();
  
  ChatMessage? get lastMessage => 
      messages.isNotEmpty ? messages.last : null;
  
  int get messageCount => messages.length;
}
