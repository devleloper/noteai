import 'package:dartz/dartz.dart';
import 'package:realm/realm.dart';
import 'package:uuid/uuid.dart' as uuid_package;
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';
import '../models/realm_models.dart';
import '../datasources/remote/ai_chat_service.dart';
import '../datasources/remote/firebase_datasource.dart';
import '../datasources/local/realm_datasource.dart';
import '../../core/services/sync/cross_device_sync_service.dart';
import '../../core/services/sync/firestore_sync_manager.dart';
import '../../core/services/sync/smart_cache.dart';
import '../../core/services/sync/offline_queue.dart';

class ChatRepositoryImpl implements ChatRepository {
  final RealmDataSource _realmDataSource;
  final AIChatService _aiService;
  final FirebaseDataSource _firebaseDataSource;
  final uuid_package.Uuid _uuid;
  final CrossDeviceSyncService _syncService;
  final FirestoreSyncManager _firestoreSyncManager;
  final SmartCache _smartCache;
  final OfflineQueue _offlineQueue;

  ChatRepositoryImpl({
    required RealmDataSource realmDataSource,
    required AIChatService aiService,
    required FirebaseDataSource firebaseDataSource,
    required uuid_package.Uuid uuid,
    required CrossDeviceSyncService syncService,
    required FirestoreSyncManager firestoreSyncManager,
    required SmartCache smartCache,
    required OfflineQueue offlineQueue,
  }) : _realmDataSource = realmDataSource,
       _aiService = aiService,
       _firebaseDataSource = firebaseDataSource,
       _uuid = uuid,
       _syncService = syncService,
       _firestoreSyncManager = firestoreSyncManager,
       _smartCache = smartCache,
       _offlineQueue = offlineQueue;

  Realm get _realm {
    try {
      return (_realmDataSource as RealmDataSourceImpl).realm;
    } catch (e) {
      throw Exception('Realm not initialized. Please ensure Realm is initialized before accessing ChatRepository.');
    }
  }

  @override
  Future<Either<Failure, ChatSession>> createSession(String recordingId) async {
    try {
      // Check if session already exists
      final existingSession = _realm.query<ChatSessionRealm>(
        'recordingId == \$0',
        [recordingId],
      ).firstOrNull;

      if (existingSession != null) {
        final sessionModel = ChatSessionModel.fromRealm(existingSession);
        return Right(sessionModel.toEntity());
      }

      // Create new session
      final sessionId = _uuid.v4();
      final now = DateTime.now();
      
      final sessionRealm = ChatSessionRealm(
        sessionId,
        recordingId,
        'gpt-4o', // default model
        now,
        now,
        summary: null,
      );

      _realm.write(() {
        _realm.add(sessionRealm);
      });

      // Sync to Firestore
      try {
        final sessionModel = ChatSessionModel.fromRealm(sessionRealm);
        await _firebaseDataSource.uploadChatSession(sessionModel.toMap());
      } catch (e) {
        print('Failed to sync session to Firestore: $e');
        // Continue without failing - local storage is primary
      }

      final sessionModel = ChatSessionModel.fromRealm(sessionRealm);
      return Right(sessionModel.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to create chat session: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> getSession(String sessionId) async {
    try {
      final sessionRealm = _realm.find<ChatSessionRealm>(sessionId);
      if (sessionRealm == null) {
        return Left(NotFoundFailure('Chat session not found'));
      }

      // Load messages separately
      final messages = _realm.query<ChatMessageRealm>(
        'sessionId == \$0',
        [sessionId],
      ).map((m) => ChatMessageModel.fromRealm(m)).toList();

      final sessionModel = ChatSessionModel.fromRealm(sessionRealm, messages: messages);
      return Right(sessionModel.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get chat session: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatSession>> getSessionByRecordingId(String recordingId) async {
    try {
      final sessionRealm = _realm.query<ChatSessionRealm>(
        'recordingId == \$0',
        [recordingId],
      ).firstOrNull;

      if (sessionRealm == null) {
        return Left(NotFoundFailure('Chat session not found for recording'));
      }

      // Load messages separately
      final messages = _realm.query<ChatMessageRealm>(
        'sessionId == \$0',
        [sessionRealm.id],
      ).map((m) => ChatMessageModel.fromRealm(m)).toList();

      final sessionModel = ChatSessionModel.fromRealm(sessionRealm, messages: messages);
      return Right(sessionModel.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get chat session: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSession(ChatSession session) async {
    try {
      final sessionRealm = _realm.find<ChatSessionRealm>(session.id);
      if (sessionRealm == null) {
        return Left(NotFoundFailure('Chat session not found'));
      }

      _realm.write(() {
        sessionRealm.summary = session.summary;
        sessionRealm.defaultModel = session.defaultModel;
        sessionRealm.updatedAt = DateTime.now();
      });

      // Sync to Firestore
      try {
        final sessionModel = ChatSessionModel.fromEntity(session);
        await _firebaseDataSource.updateChatSession(session.id, sessionModel.toMap());
      } catch (e) {
        print('Failed to sync session update to Firestore: $e');
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update chat session: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      final sessionRealm = _realm.find<ChatSessionRealm>(sessionId);
      if (sessionRealm == null) {
        return Left(NotFoundFailure('Chat session not found'));
      }

      _realm.write(() {
        _realm.delete(sessionRealm);
      });

      // Delete from Firestore
      try {
        await _firebaseDataSource.deleteChatSession(sessionId);
      } catch (e) {
        print('Failed to delete session from Firestore: $e');
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete chat session: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(String sessionId) async {
    try {
      final sessionRealm = _realm.find<ChatSessionRealm>(sessionId);
      if (sessionRealm == null) {
        return Left(NotFoundFailure('Chat session not found'));
      }

      final messages = _realm.query<ChatMessageRealm>(
        'sessionId == \$0',
        [sessionId],
      ).map((m) => ChatMessageModel.fromRealm(m).toEntity()).toList();

      return Right(messages);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get messages: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(SendMessageParams params) async {
    try {
      final sessionRealm = _realm.find<ChatSessionRealm>(params.sessionId);
      if (sessionRealm == null) {
        return Left(NotFoundFailure('Chat session not found'));
      }

      // Create user message
      final userMessageId = _uuid.v4();
      final userMessage = ChatMessageRealm(
        userMessageId,
        params.sessionId,
        MessageType.user.name,
        params.content,
        DateTime.now(),
        model: null,
        parentMessageId: params.parentMessageId,
        metadata: null,
      );

      _realm.write(() {
        _realm.add(userMessage);
        sessionRealm.updatedAt = DateTime.now();
      });

      // Get AI response - load existing messages for context
      final existingMessages = _realm.query<ChatMessageRealm>(
        'sessionId == \$0',
        [params.sessionId],
      ).map((m) => ChatMessageModel.fromRealm(m).toEntity()).toList();
      
      final context = existingMessages;
      
      final model = params.model ?? sessionRealm.defaultModel;
      final aiResponse = await _aiService.generateContextualResponse(
        message: params.content,
        model: model,
        context: context,
        recordingContext: sessionRealm.summary ?? 'No context available',
      );

      // Create AI message
      final aiMessageId = _uuid.v4();
      final aiMessage = ChatMessageRealm(
        aiMessageId,
        params.sessionId,
        MessageType.ai.name,
        aiResponse,
        DateTime.now(),
        model: model,
        parentMessageId: userMessageId,
        metadata: null,
      );

      _realm.write(() {
        _realm.add(aiMessage);
        sessionRealm.updatedAt = DateTime.now();
      });

      // Sync to Firestore
      try {
        final messages = _realm.query<ChatMessageRealm>(
          'sessionId == \$0',
          [params.sessionId],
        ).map((m) => ChatMessageModel.fromRealm(m)).toList();
        
        final updatedSessionModel = ChatSessionModel.fromRealm(sessionRealm, messages: messages);
        await _firebaseDataSource.updateChatSession(
          params.sessionId,
          updatedSessionModel.toMap(),
        );
      } catch (e) {
        print('Failed to sync messages to Firestore: $e');
      }

      final aiMessageModel = ChatMessageModel.fromRealm(aiMessage);
      return Right(aiMessageModel.toEntity());
    } catch (e) {
      if (e is AIException) {
        return Left(AIFailure(e.message));
      }
      return Left(DatabaseFailure('Failed to send message: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> regenerateMessage(RegenerateMessageParams params) async {
    try {
      final sessionRealm = _realm.find<ChatSessionRealm>(params.sessionId);
      if (sessionRealm == null) {
        return Left(NotFoundFailure('Chat session not found'));
      }

      // Find the message to regenerate
      final messageToRegenerate = _realm.find<ChatMessageRealm>(params.messageId);
      if (messageToRegenerate == null) {
        return Left(NotFoundFailure('Message not found'));
      }

      if (messageToRegenerate.type != MessageType.ai.name) {
        return Left(ValidationFailure('Can only regenerate AI messages'));
      }

      // Get context up to the message being regenerated
      final allMessages = _realm.query<ChatMessageRealm>(
        'sessionId == \$0',
        [params.sessionId],
      ).toList();
      
      final messageIndex = allMessages.indexWhere((m) => m.id == params.messageId);
      final context = allMessages
          .take(messageIndex)
          .map((m) => ChatMessageModel.fromRealm(m).toEntity())
          .toList();

      // Generate new response
      final model = params.model ?? sessionRealm.defaultModel;
      final sessionModel = ChatSessionModel.fromRealm(sessionRealm);
      final newResponse = await _aiService.generateContextualResponse(
        message: context.isNotEmpty ? context.last.content : '',
        model: model,
        context: context,
        recordingContext: sessionModel.summary ?? 'No context available',
      );

      // Update the message
      _realm.write(() {
        messageToRegenerate.content = newResponse;
        messageToRegenerate.model = model;
        sessionRealm.updatedAt = DateTime.now();
      });

      // Sync to Firestore
      try {
        final updatedSessionModel = ChatSessionModel.fromRealm(sessionRealm);
        await _firebaseDataSource.updateChatSession(
          params.sessionId,
          updatedSessionModel.toMap(),
        );
      } catch (e) {
        print('Failed to sync regenerated message to Firestore: $e');
      }

      final updatedMessageModel = ChatMessageModel.fromRealm(messageToRegenerate);
      return Right(updatedMessageModel.toEntity());
    } catch (e) {
      if (e is AIException) {
        return Left(AIFailure(e.message));
      }
      return Left(DatabaseFailure('Failed to regenerate message: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      final messageRealm = _realm.find<ChatMessageRealm>(messageId);
      if (messageRealm == null) {
        return Left(NotFoundFailure('Message not found'));
      }

      final sessionId = messageRealm.sessionId;
      final sessionRealm = _realm.find<ChatSessionRealm>(sessionId);
      if (sessionRealm == null) {
        return Left(NotFoundFailure('Chat session not found'));
      }

      _realm.write(() {
        _realm.delete(messageRealm);
        sessionRealm.updatedAt = DateTime.now();
      });

      // Sync to Firestore
      try {
        final sessionModel = ChatSessionModel.fromRealm(sessionRealm);
        await _firebaseDataSource.updateChatSession(
          sessionId,
          sessionModel.toMap(),
        );
      } catch (e) {
        print('Failed to sync message deletion to Firestore: $e');
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete message: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generateSummary(GenerateSummaryParams params) async {
    try {
      final summary = await _aiService.generateSummary(
        transcript: params.transcript,
        model: params.model,
        language: params.language,
      );

      // Update session with summary
      final sessionRealm = _realm.query<ChatSessionRealm>(
        'recordingId == \$0',
        [params.recordingId],
      ).firstOrNull;

      if (sessionRealm != null) {
        _realm.write(() {
          sessionRealm.summary = summary;
          sessionRealm.updatedAt = DateTime.now();
        });

        // Sync to Firestore
        try {
          final sessionModel = ChatSessionModel.fromRealm(sessionRealm);
          await _firebaseDataSource.updateChatSession(
            sessionRealm.id,
            sessionModel.toMap(),
          );
        } catch (e) {
          print('Failed to sync summary to Firestore: $e');
        }
      }

      return Right(summary);
    } catch (e) {
      if (e is AIException) {
        return Left(AIFailure(e.message));
      }
      return Left(DatabaseFailure('Failed to generate summary: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateSummary(String sessionId, String summary) async {
    try {
      final sessionRealm = _realm.find<ChatSessionRealm>(sessionId);
      if (sessionRealm == null) {
        return Left(NotFoundFailure('Chat session not found'));
      }

      _realm.write(() {
        sessionRealm.summary = summary;
        sessionRealm.updatedAt = DateTime.now();
      });

      // Sync to Firestore
      try {
        final sessionModel = ChatSessionModel.fromRealm(sessionRealm);
        await _firebaseDataSource.updateChatSession(
          sessionId,
          sessionModel.toMap(),
        );
      } catch (e) {
        print('Failed to sync summary update to Firestore: $e');
      }

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update summary: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getDefaultModel() async {
    try {
      // For now, return a default model. In the future, this could be stored in preferences
      return const Right('gpt-4o');
    } catch (e) {
      return Left(DatabaseFailure('Failed to get default model: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultModel(String model) async {
    try {
      // For now, this is a no-op. In the future, this could be stored in preferences
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to set default model: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableModels() async {
    try {
      return Right(AIChatService.supportedModels);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get available models: $e'));
    }
  }
}
