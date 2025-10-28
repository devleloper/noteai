import 'package:realm/realm.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/recording_model.dart';
import '../../models/realm_models.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/chat_message.dart';

abstract class RealmDataSource {
  Realm get realm;
  Future<void> saveRecording(RecordingModel recording);
  Future<List<RecordingModel>> getRecordings();
  Future<RecordingModel?> getRecording(String id);
  Future<void> deleteRecording(String id);
  Future<void> updateRecording(RecordingModel recording);
  Future<void> initialize();
  Future<void> close();
  
  // Chat session methods
  Future<ChatSessionRealm?> getChatSessionByRecordingId(String recordingId);
  Future<void> createChatSessionFromRemote(Map<String, dynamic> chatData);
  Future<void> createChatMessagesFromRemote(String recordingId, List<Map<String, dynamic>> messages);
}

class RealmDataSourceImpl implements RealmDataSource {
  Realm? _realm;
  
  Realm get realm {
    if (_realm == null) {
      throw CacheException('Realm not initialized');
    }
    return _realm!;
  }
  
  @override
  Future<void> initialize() async {
    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final realmPath = '${appDir.path}/noteai.realm';
      
      // Initialize Realm with schema
      final config = Configuration.local([
        RecordingRealm.schema,
        ChatSessionRealm.schema,
        ChatMessageRealm.schema,
        SummarizationStateRealm.schema,
      ], path: realmPath);
      
      _realm = Realm(config);
    } catch (e) {
      throw CacheException('Failed to initialize Realm: $e');
    }
  }
  
  @override
  Future<void> saveRecording(RecordingModel recording) async {
    try {
      if (_realm == null) {
        await initialize();
      }
      
      final realmRecording = RecordingRealmExtension.fromEntity(recording.toEntity());
      _realm!.write(() {
        _realm!.add(realmRecording);
      });
    } catch (e) {
      throw CacheException('Failed to save recording: $e');
    }
  }
  
  @override
  Future<List<RecordingModel>> getRecordings() async {
    try {
      if (_realm == null) {
        await initialize();
      }
      
      final realmRecordings = _realm!.all<RecordingRealm>();
      return realmRecordings.map((realm) => 
        RecordingModel.fromEntity(realm.toEntity())
      ).toList();
    } catch (e) {
      throw CacheException('Failed to get recordings: $e');
    }
  }
  
  @override
  Future<RecordingModel?> getRecording(String id) async {
    try {
      if (_realm == null) {
        await initialize();
      }
      
      final realmRecording = _realm!.find<RecordingRealm>(id);
      if (realmRecording == null) return null;
      
      return RecordingModel.fromEntity(realmRecording.toEntity());
    } catch (e) {
      throw CacheException('Failed to get recording: $e');
    }
  }
  
  @override
  Future<void> deleteRecording(String id) async {
    try {
      if (_realm == null) {
        await initialize();
      }
      
      final realmRecording = _realm!.find<RecordingRealm>(id);
      if (realmRecording != null) {
        _realm!.write(() {
          _realm!.delete(realmRecording);
        });
      }
    } catch (e) {
      throw CacheException('Failed to delete recording: $e');
    }
  }
  
  @override
  Future<void> updateRecording(RecordingModel recording) async {
    try {
      if (_realm == null) {
        await initialize();
      }
      
      final realmRecording = _realm!.find<RecordingRealm>(recording.id);
      if (realmRecording != null) {
        _realm!.write(() {
          realmRecording.title = recording.title;
          realmRecording.audioPath = recording.audioPath;
          realmRecording.durationMs = recording.duration.inMilliseconds;
          realmRecording.updatedAt = DateTime.now();
          realmRecording.recordingStatus = recording.status;
          realmRecording.progress = recording.progress;
          realmRecording.transcript = recording.transcript;
          realmRecording.summary = recording.summary;
          realmRecording.isSynced = recording.isSynced;
        });
      }
    } catch (e) {
      throw CacheException('Failed to update recording: $e');
    }
  }
  
  @override
  Future<void> close() async {
    try {
      _realm?.close();
      _realm = null;
    } catch (e) {
      throw CacheException('Failed to close Realm: $e');
    }
  }
  
  // Chat session methods
  
  @override
  Future<ChatSessionRealm?> getChatSessionByRecordingId(String recordingId) async {
    try {
      if (_realm == null) {
        await initialize();
      }
      
      final chatSession = _realm!.query<ChatSessionRealm>(
        'recordingId == \$0',
        [recordingId],
      ).firstOrNull;
      
      return chatSession;
    } catch (e) {
      throw CacheException('Failed to get chat session by recording ID: $e');
    }
  }
  
  @override
  Future<void> createChatSessionFromRemote(Map<String, dynamic> chatData) async {
    try {
      if (_realm == null) {
        await initialize();
      }
      
      // Safely extract data with proper type conversion
      final chatId = chatData['chatId']?.toString();
      final recordingId = chatData['recordingId']?.toString();
      final summary = chatData['summary']?.toString();
      final defaultModel = chatData['defaultModel']?.toString() ?? 'gpt-4o';
      
      // Handle different timestamp formats
      DateTime? createdAt;
      DateTime? updatedAt;
      
      if (chatData['createdAt'] is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(chatData['createdAt'] as int);
      } else if (chatData['createdAt'] is String) {
        createdAt = DateTime.tryParse(chatData['createdAt'] as String);
      }
      createdAt ??= DateTime.now();
      
      if (chatData['updatedAt'] is int) {
        updatedAt = DateTime.fromMillisecondsSinceEpoch(chatData['updatedAt'] as int);
      } else if (chatData['updatedAt'] is String) {
        updatedAt = DateTime.tryParse(chatData['updatedAt'] as String);
      }
      updatedAt ??= DateTime.now();
      
      if (chatId != null && recordingId != null) {
        final chatSessionRealm = ChatSessionRealm(
          chatId,
          recordingId,
          defaultModel,
          createdAt,
          updatedAt,
          summary: summary,
        );
        
        _realm!.write(() {
          _realm!.add(chatSessionRealm);
        });
        
        print('RealmDataSource: Created chat session $chatId for recording $recordingId');
      }
    } catch (e) {
      print('RealmDataSource: Error creating chat session from remote: $e');
      print('RealmDataSource: Chat data: $chatData');
      throw CacheException('Failed to create chat session from remote: $e');
    }
  }
  
  @override
  Future<void> createChatMessagesFromRemote(String recordingId, List<Map<String, dynamic>> messages) async {
    try {
      if (_realm == null) {
        await initialize();
      }
      
      // Get the chat session for this recording
      final chatSession = await getChatSessionByRecordingId(recordingId);
      if (chatSession == null) {
        print('RealmDataSource: No chat session found for recording $recordingId');
        return;
      }
      
      for (final messageData in messages) {
        try {
          final messageId = messageData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
          final content = messageData['content']?.toString() ?? '';
          final role = messageData['role']?.toString() ?? 'user';
          final model = messageData['model']?.toString();
          
          // Handle timestamp
          DateTime? timestamp;
          if (messageData['timestamp'] is int) {
            timestamp = DateTime.fromMillisecondsSinceEpoch(messageData['timestamp'] as int);
          } else if (messageData['timestamp'] is String) {
            timestamp = DateTime.tryParse(messageData['timestamp'] as String);
          }
          timestamp ??= DateTime.now();
          
          // Determine message type
          MessageType messageType;
          if (role == 'user') {
            messageType = MessageType.user;
          } else if (role == 'assistant' || role == 'ai') {
            messageType = MessageType.ai;
          } else {
            messageType = MessageType.system;
          }
          
          final chatMessageRealm = ChatMessageRealm(
            messageId,
            chatSession.id,
            messageType.name,
            content,
            timestamp,
            model: model,
            parentMessageId: null,
            metadata: null,
          );
          
          _realm!.write(() {
            _realm!.add(chatMessageRealm);
          });
          
          print('RealmDataSource: Created message $messageId for session ${chatSession.id}');
        } catch (e) {
          print('RealmDataSource: Error creating message: $e');
          print('RealmDataSource: Message data: $messageData');
        }
      }
    } catch (e) {
      print('RealmDataSource: Error creating chat messages from remote: $e');
      throw CacheException('Failed to create chat messages from remote: $e');
    }
  }
}