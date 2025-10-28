import 'package:realm/realm.dart';
import '../../domain/entities/chat_message.dart';
import 'realm_models.dart';

class ChatMessageModel {
  final String id;
  final String sessionId;
  final MessageType type;
  final String content;
  final String? model;
  final DateTime timestamp;
  final String? parentMessageId;
  final Map<String, dynamic>? metadata;

  const ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.content,
    this.model,
    required this.timestamp,
    this.parentMessageId,
    this.metadata,
  });

  // Convert to Realm model
  ChatMessageRealm toRealm() {
    return ChatMessageRealm(
      id,
      sessionId,
      type.name,
      content,
      timestamp,
      model: model,
      parentMessageId: parentMessageId,
      metadata: metadata != null ? _encodeMetadata(metadata!) : null,
    );
  }

  // Convert from Realm model
  factory ChatMessageModel.fromRealm(ChatMessageRealm realm) {
    return ChatMessageModel(
      id: realm.id,
      sessionId: realm.sessionId,
      type: MessageType.values.firstWhere(
        (e) => e.name == realm.type,
        orElse: () => MessageType.user,
      ),
      content: realm.content,
      model: realm.model,
      timestamp: realm.timestamp,
      parentMessageId: realm.parentMessageId,
      metadata: realm.metadata != null ? _decodeMetadata(realm.metadata!) : null,
    );
  }

  // Convert to Entity
  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      sessionId: sessionId,
      type: type,
      content: content,
      model: model,
      timestamp: timestamp,
      parentMessageId: parentMessageId,
      metadata: metadata,
    );
  }

  // Convert from Entity
  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      sessionId: entity.sessionId,
      type: entity.type,
      content: entity.content,
      model: entity.model,
      timestamp: entity.timestamp,
      parentMessageId: entity.parentMessageId,
      metadata: entity.metadata,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'type': type.name,
      'content': content,
      'model': model,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'parentMessageId': parentMessageId,
      'metadata': metadata,
    };
  }

  // Convert from Map (Firestore)
  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] ?? '',
      sessionId: map['sessionId'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.user,
      ),
      content: map['content'] ?? '',
      model: map['model'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      parentMessageId: map['parentMessageId'],
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  // Helper methods for metadata serialization
  static String _encodeMetadata(Map<String, dynamic> metadata) {
    // Simple JSON encoding - in production, use proper JSON encoding
    return metadata.toString();
  }

  static Map<String, dynamic> _decodeMetadata(String metadata) {
    // Simple JSON decoding - in production, use proper JSON decoding
    return <String, dynamic>{};
  }
}
