import 'package:realm/realm.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/chat_message.dart';
import 'chat_message_model.dart';
import 'realm_models.dart';

class ChatSessionModel {
  final String id;
  final String recordingId;
  final String? summary;
  final String defaultModel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessageModel> messages;

  const ChatSessionModel({
    required this.id,
    required this.recordingId,
    this.summary,
    required this.defaultModel,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  // Convert to Realm model
  ChatSessionRealm toRealm() {
    return ChatSessionRealm(
      id,
      recordingId,
      defaultModel,
      createdAt,
      updatedAt,
      summary: summary,
    );
  }

  // Convert from Realm model
  factory ChatSessionModel.fromRealm(ChatSessionRealm realm, {List<ChatMessageModel> messages = const []}) {
    return ChatSessionModel(
      id: realm.id,
      recordingId: realm.recordingId,
      summary: realm.summary,
      defaultModel: realm.defaultModel,
      createdAt: realm.createdAt,
      updatedAt: realm.updatedAt,
      messages: messages,
    );
  }

  // Convert to Entity
  ChatSession toEntity() {
    return ChatSession(
      id: id,
      recordingId: recordingId,
      summary: summary,
      defaultModel: defaultModel,
      createdAt: createdAt,
      updatedAt: updatedAt,
      messages: messages.map((m) => m.toEntity()).toList(),
    );
  }

  // Convert from Entity
  factory ChatSessionModel.fromEntity(ChatSession entity) {
    return ChatSessionModel(
      id: entity.id,
      recordingId: entity.recordingId,
      summary: entity.summary,
      defaultModel: entity.defaultModel,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      messages: entity.messages.map((m) => ChatMessageModel.fromEntity(m)).toList(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recordingId': recordingId,
      'summary': summary,
      'defaultModel': defaultModel,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  // Convert from Map (Firestore)
  factory ChatSessionModel.fromMap(Map<String, dynamic> map) {
    return ChatSessionModel(
      id: map['id'] ?? '',
      recordingId: map['recordingId'] ?? '',
      summary: map['summary'],
      defaultModel: map['defaultModel'] ?? 'gpt-4o',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      messages: (map['messages'] as List<dynamic>?)
          ?.map((m) => ChatMessageModel.fromMap(Map<String, dynamic>.from(m)))
          .toList() ?? [],
    );
  }
}
