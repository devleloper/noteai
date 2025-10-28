import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/sync/sync_models.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/chat_session.dart';
import '../../utils/service_locator.dart' as di;
import 'firestore_sync_manager.dart';
import 'smart_cache.dart';
import 'offline_queue.dart';

/// Service for ensuring consistent chat history across all devices
class ChatConsistencyService {
  static final ChatConsistencyService _instance = ChatConsistencyService._internal();
  factory ChatConsistencyService() => _instance;
  ChatConsistencyService._internal();

  late FirestoreSyncManager _firestoreSyncManager;
  late SmartCache _smartCache;
  late OfflineQueue _offlineQueue;
  late FirebaseAuth _auth;

  String? _currentUserId;
  String? _currentDeviceId;

  Future<void> initialize() async {
    _firestoreSyncManager = di.sl<FirestoreSyncManager>();
    _smartCache = di.sl<SmartCache>();
    _offlineQueue = di.sl<OfflineQueue>();
    _auth = FirebaseAuth.instance;

    _currentUserId = _auth.currentUser?.uid;
    _currentDeviceId = await _getCurrentDeviceId();

    _auth.authStateChanges().listen((user) {
      _currentUserId = user?.uid;
      _getCurrentDeviceId().then((deviceId) => _currentDeviceId = deviceId);
    });

    print('ChatConsistencyService: Initialized');
  }

  /// Ensure consistent message ordering across devices
  Future<List<ChatMessage>> ensureConsistentMessageOrder(
    String sessionId,
    List<ChatMessage> messages,
  ) async {
    try {
      // Sort messages by timestamp (oldest first)
      final sortedMessages = List<ChatMessage>.from(messages);
      sortedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Remove duplicates based on message ID
      final uniqueMessages = <String, ChatMessage>{};
      for (final message in sortedMessages) {
        uniqueMessages[message.id] = message;
      }

      // Convert back to list
      final deduplicatedMessages = uniqueMessages.values.toList();
      deduplicatedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      print('ChatConsistencyService: Ensured consistent order for ${deduplicatedMessages.length} messages');
      return deduplicatedMessages;
    } catch (e) {
      print('ChatConsistencyService: Error ensuring consistent order: $e');
      return messages; // Return original if error
    }
  }

  /// Sync chat messages with conflict resolution
  Future<void> syncChatMessages(String sessionId) async {
    if (_currentUserId == null) {
      print('ChatConsistencyService: No user authenticated');
      return;
    }

    try {
      // Get local messages
      final localMessages = await _getLocalMessages(sessionId);
      
      // Get remote messages
      final remoteMessages = await _getRemoteMessages(sessionId);
      
      // Merge and resolve conflicts
      final mergedMessages = await _mergeMessages(localMessages, remoteMessages);
      
      // Update local storage
      await _updateLocalMessages(sessionId, mergedMessages);
      
      // Update remote storage
      await _updateRemoteMessages(sessionId, mergedMessages);
      
      print('ChatConsistencyService: Synced ${mergedMessages.length} messages for session $sessionId');
    } catch (e) {
      print('ChatConsistencyService: Error syncing chat messages: $e');
      // Add to offline queue for retry
      await _offlineQueue.addOperation(SyncOperation(
        id: 'sync_chat_messages_$sessionId',
        type: 'sync',
        entityId: sessionId,
        data: {'sessionId': sessionId},
        timestamp: DateTime.now(),
        retryCount: 0,
      ));
    }
  }

  /// Merge local and remote messages with conflict resolution
  Future<List<ChatMessage>> _mergeMessages(
    List<ChatMessage> localMessages,
    List<ChatMessage> remoteMessages,
  ) async {
    final mergedMessages = <String, ChatMessage>{};
    
    // Add local messages
    for (final message in localMessages) {
      mergedMessages[message.id] = message;
    }
    
    // Add remote messages (remote wins in case of conflict)
    for (final message in remoteMessages) {
      if (mergedMessages.containsKey(message.id)) {
        // Conflict resolution: use the message with later timestamp
        final existingMessage = mergedMessages[message.id]!;
        if (message.timestamp.isAfter(existingMessage.timestamp)) {
          mergedMessages[message.id] = message;
          print('ChatConsistencyService: Resolved conflict for message ${message.id} - using remote version');
        }
      } else {
        mergedMessages[message.id] = message;
      }
    }
    
    // Convert to list and sort
    final result = mergedMessages.values.toList();
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return result;
  }

  /// Get local messages from cache
  Future<List<ChatMessage>> _getLocalMessages(String sessionId) async {
    try {
      final cachedMessages = await _smartCache.getCachedChatMessages(sessionId);
      if (cachedMessages != null) {
        return cachedMessages.map((data) => _mapToChatMessage(data)).toList();
      }
      return [];
    } catch (e) {
      print('ChatConsistencyService: Error getting local messages: $e');
      return [];
    }
  }

  /// Get remote messages from Firestore
  Future<List<ChatMessage>> _getRemoteMessages(String sessionId) async {
    try {
      final remoteMessages = await _firestoreSyncManager.getChatMessages(sessionId);
      return remoteMessages.map((data) => _mapToChatMessage(data)).toList();
    } catch (e) {
      print('ChatConsistencyService: Error getting remote messages: $e');
      return [];
    }
  }

  /// Update local messages in cache
  Future<void> _updateLocalMessages(String sessionId, List<ChatMessage> messages) async {
    try {
      final messageData = messages.map((msg) => _mapToMap(msg)).toList();
      await _smartCache.cacheChatMessages(
        recordingId: sessionId,
        messages: messageData,
      );
    } catch (e) {
      print('ChatConsistencyService: Error updating local messages: $e');
    }
  }

  /// Update remote messages in Firestore
  Future<void> _updateRemoteMessages(String sessionId, List<ChatMessage> messages) async {
    try {
      for (final message in messages) {
        await _firestoreSyncManager.syncChatMessage(
          recordingId: sessionId,
          messageId: message.id,
          content: message.content,
          role: message.type.name,
          timestamp: message.timestamp,
          model: message.model,
        );
      }
    } catch (e) {
      print('ChatConsistencyService: Error updating remote messages: $e');
    }
  }

  /// Map data to ChatMessage entity
  ChatMessage _mapToChatMessage(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] as String,
      sessionId: data['sessionId'] as String,
      type: MessageType.values.firstWhere(
        (type) => type.name == data['type'],
        orElse: () => MessageType.user,
      ),
      content: data['content'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
      model: data['model'] as String?,
      parentMessageId: data['parentMessageId'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Map ChatMessage to Map
  Map<String, dynamic> _mapToMap(ChatMessage message) {
    return {
      'id': message.id,
      'sessionId': message.sessionId,
      'type': message.type.name,
      'content': message.content,
      'timestamp': message.timestamp.toIso8601String(),
      'model': message.model,
      'parentMessageId': message.parentMessageId,
      'metadata': message.metadata,
    };
  }

  /// Get current device ID
  Future<String> _getCurrentDeviceId() async {
    // TODO: Implement proper device ID generation
    // For now, use a simple approach
    return 'device_${_currentUserId ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Validate message consistency
  Future<bool> validateMessageConsistency(String sessionId) async {
    try {
      final localMessages = await _getLocalMessages(sessionId);
      final remoteMessages = await _getRemoteMessages(sessionId);
      
      // Check if message counts match
      if (localMessages.length != remoteMessages.length) {
        print('ChatConsistencyService: Message count mismatch - Local: ${localMessages.length}, Remote: ${remoteMessages.length}');
        return false;
      }
      
      // Check if all message IDs match
      final localIds = localMessages.map((m) => m.id).toSet();
      final remoteIds = remoteMessages.map((m) => m.id).toSet();
      
      if (!localIds.containsAll(remoteIds) || !remoteIds.containsAll(localIds)) {
        print('ChatConsistencyService: Message ID mismatch');
        return false;
      }
      
      print('ChatConsistencyService: Message consistency validated for session $sessionId');
      return true;
    } catch (e) {
      print('ChatConsistencyService: Error validating consistency: $e');
      return false;
    }
  }

  /// Force sync all chat sessions
  Future<void> forceSyncAllChatSessions() async {
    if (_currentUserId == null) return;

    try {
      // Get all chat sessions
      final chatSessions = await _firestoreSyncManager.getChats();
      
      for (final sessionData in chatSessions) {
        final sessionId = sessionData['chatId'] as String?;
        if (sessionId != null) {
          await syncChatMessages(sessionId);
        }
      }
      
      print('ChatConsistencyService: Force synced all chat sessions');
    } catch (e) {
      print('ChatConsistencyService: Error force syncing all sessions: $e');
    }
  }
}
