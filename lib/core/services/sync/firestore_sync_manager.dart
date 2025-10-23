import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/sync/sync_models.dart';

/// Manages real-time Firestore synchronization
class FirestoreSyncManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<QuerySnapshot>? _transcriptsSubscription;
  StreamSubscription<QuerySnapshot>? _chatsSubscription;
  StreamSubscription<QuerySnapshot>? _audioMetadataSubscription;
  
  String? _currentUserId;
  bool _isListening = false;

  /// Initialize the sync manager
  Future<void> initialize() async {
    _currentUserId = _auth.currentUser?.uid;
    
    // Listen for auth state changes
    _auth.authStateChanges().listen((user) {
      _currentUserId = user?.uid;
      if (_isListening) {
        // Restart listeners when user changes
        stopListening();
        if (_currentUserId != null) {
          startListening();
        }
      }
    });
    
    if (_currentUserId == null) {
      print('FirestoreSyncManager: No authenticated user at init (will update on auth change)');
      return;
    }
    print('FirestoreSyncManager: Initialized for user $_currentUserId');
  }

  /// Get transcripts from Firestore
  Future<List<Map<String, dynamic>>> getTranscripts() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recordings')
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['recordingId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('FirestoreSyncManager: Error fetching transcripts: $e');
      return [];
    }
  }

  /// Get chats from Firestore
  Future<List<Map<String, dynamic>>> getChats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['chatId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('FirestoreSyncManager: Error fetching chats: $e');
      return [];
    }
  }

  /// Sync audio metadata to Firestore
  Future<void> syncAudioMetadata(AudioMetadata metadata) async {
    if (_currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('audioMetadata')
          .doc(metadata.recordingId)
          .set(metadata.toJson());
      
      print('FirestoreSyncManager: Synced audio metadata for ${metadata.recordingId}');
    } catch (e) {
      print('FirestoreSyncManager: Error syncing audio metadata: $e');
      rethrow;
    }
  }

  /// Get audio metadata from Firestore
  Future<AudioMetadata?> getAudioMetadata(String recordingId) async {
    if (_currentUserId == null) return null;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('audioMetadata')
          .doc(recordingId)
          .get();
      
      if (doc.exists) {
        return AudioMetadata.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('FirestoreSyncManager: Error fetching audio metadata: $e');
      return null;
    }
  }

  /// Get all audio metadata from Firestore
  Future<List<AudioMetadata>> getAllAudioMetadata() async {
    if (_currentUserId == null) return [];
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('audioMetadata')
          .get();
      
      return querySnapshot.docs.map((doc) => AudioMetadata.fromJson(doc.data())).toList();
    } catch (e) {
      print('FirestoreSyncManager: Error fetching all audio metadata: $e');
      return [];
    }
  }

  /// Delete audio metadata from Firestore
  Future<void> deleteAudioMetadata(String recordingId) async {
    if (_currentUserId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('audioMetadata')
          .doc(recordingId)
          .delete();
      
      print('FirestoreSyncManager: Deleted audio metadata for $recordingId');
    } catch (e) {
      print('FirestoreSyncManager: Error deleting audio metadata: $e');
      rethrow;
    }
  }

  /// Start real-time listeners
  Future<void> startListening() async {
    if (_currentUserId == null || _isListening) return;

    try {
      await _startTranscriptsListener();
      await _startChatsListener();
      await _startAudioMetadataListener();
      
      _isListening = true;
      print('FirestoreSyncManager: Real-time listeners started');
    } catch (e) {
      print('FirestoreSyncManager: Error starting listeners: $e');
    }
  }

  /// Stop real-time listeners
  Future<void> stopListening() async {
    await _transcriptsSubscription?.cancel();
    await _chatsSubscription?.cancel();
    await _audioMetadataSubscription?.cancel();
    
    _isListening = false;
    print('FirestoreSyncManager: Real-time listeners stopped');
  }

  /// Sync transcript to Firestore
  Future<void> syncTranscript({
    required String transcriptId,
    required String content,
    required String recordingId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('transcripts')
          .doc(transcriptId)
          .set({
        'content': content,
        'recordingId': recordingId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deviceId': await _getCurrentDeviceId(),
        'syncTimestamp': FieldValue.serverTimestamp(),
      });

      print('FirestoreSyncManager: Transcript $transcriptId synced');
    } catch (e) {
      print('FirestoreSyncManager: Error syncing transcript: $e');
      rethrow;
    }
  }

  /// Sync chat message to Firestore
  Future<void> syncChatMessage({
    required String messageId,
    required String content,
    required String recordingId,
    required String role,
    required DateTime timestamp,
    required String? model,
  }) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('chats')
          .doc(recordingId)
          .collection('messages')
          .doc(messageId)
          .set({
        'content': content,
        'role': role,
        'timestamp': timestamp.toIso8601String(),
        'model': model,
        'deviceId': await _getCurrentDeviceId(),
        'syncTimestamp': FieldValue.serverTimestamp(),
      });

      print('FirestoreSyncManager: Chat message $messageId synced');
    } catch (e) {
      print('FirestoreSyncManager: Error syncing chat message: $e');
      rethrow;
    }
  }



  /// Get chat messages for a recording
  Future<List<Map<String, dynamic>>> getChatMessages(String recordingId) async {
    if (_currentUserId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('chats')
          .doc(recordingId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('FirestoreSyncManager: Error getting chat messages: $e');
      return [];
    }
  }

  /// Get audio metadata from Firestore

  /// Delete transcript from Firestore
  Future<void> deleteTranscript(String transcriptId) async {
    if (_currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('transcripts')
          .doc(transcriptId)
          .delete();

      print('FirestoreSyncManager: Transcript $transcriptId deleted');
    } catch (e) {
      print('FirestoreSyncManager: Error deleting transcript: $e');
      rethrow;
    }
  }

  /// Delete chat messages for a recording
  Future<void> deleteChatMessages(String recordingId) async {
    if (_currentUserId == null) return;

    try {
      final batch = _firestore.batch();
      final messagesSnapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('chats')
          .doc(recordingId)
          .collection('messages')
          .get();

      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('FirestoreSyncManager: Chat messages for $recordingId deleted');
    } catch (e) {
      print('FirestoreSyncManager: Error deleting chat messages: $e');
      rethrow;
    }
  }


  /// Dispose resources
  Future<void> dispose() async {
    await stopListening();
    print('FirestoreSyncManager: Disposed');
  }

  // Private methods

  Future<void> _startTranscriptsListener() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _transcriptsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('recordings')
        .snapshots()
        .listen((snapshot) {
      print('FirestoreSyncManager: Recordings updated - ${snapshot.docs.length} documents');
      // TODO: Handle recording updates
    });
  }

  Future<void> _startChatsListener() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _chatsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .snapshots()
        .listen((snapshot) {
      print('FirestoreSyncManager: Chats updated - ${snapshot.docs.length} documents');
      // TODO: Handle chat updates
    });
  }

  Future<void> _startAudioMetadataListener() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _audioMetadataSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('audioMetadata')
        .snapshots()
        .listen((snapshot) {
      print('FirestoreSyncManager: Audio metadata updated - ${snapshot.docs.length} documents');
      // TODO: Handle audio metadata updates
    });
  }

  Future<String> _getCurrentDeviceId() async {
    // TODO: Get actual device ID from device_info_plus
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }
}
