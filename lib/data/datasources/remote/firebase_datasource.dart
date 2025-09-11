import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/recording_model.dart';

abstract class FirebaseDataSource {
  Future<void> uploadRecording(RecordingModel recording);
  Future<List<RecordingModel>> getRecordings();
  Future<RecordingModel?> getRecording(String id);
  Future<void> deleteRecording(String id);
  Future<void> updateRecording(RecordingModel recording);
  
  // Chat session methods
  Future<void> uploadChatSession(Map<String, dynamic> session);
  Future<void> updateChatSession(String sessionId, Map<String, dynamic> session);
  Future<void> deleteChatSession(String sessionId);
  Future<Map<String, dynamic>?> getChatSession(String sessionId);
}

class FirebaseDataSourceImpl implements FirebaseDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  
  FirebaseDataSourceImpl(this.firestore, this.firebaseAuth);
  
  @override
  Future<void> uploadRecording(RecordingModel recording) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    final docRef = firestore
        .collection('users')
        .doc(user.uid)
        .collection('recordings')
        .doc(recording.id);
    
    await docRef.set(recording.toMap());
  }
  
  @override
  Future<List<RecordingModel>> getRecordings() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    final querySnapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('recordings')
        .orderBy('createdAt', descending: true)
        .get();
    
    return querySnapshot.docs
        .map((doc) => RecordingModel.fromMap(doc.data(), doc.id))
        .toList();
  }
  
  @override
  Future<RecordingModel?> getRecording(String id) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    final doc = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('recordings')
        .doc(id)
        .get();
    
    if (!doc.exists) {
      return null;
    }
    
    return RecordingModel.fromMap(doc.data()!, doc.id);
  }
  
  @override
  Future<void> deleteRecording(String id) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('recordings')
        .doc(id)
        .delete();
  }
  
  @override
  Future<void> updateRecording(RecordingModel recording) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('recordings')
        .doc(recording.id)
        .update(recording.toMap());
  }

  @override
  Future<void> uploadChatSession(Map<String, dynamic> session) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    final docRef = firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_sessions')
        .doc(session['id']);
    
    await docRef.set(session);
  }

  @override
  Future<void> updateChatSession(String sessionId, Map<String, dynamic> session) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_sessions')
        .doc(sessionId)
        .update(session);
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_sessions')
        .doc(sessionId)
        .delete();
  }

  @override
  Future<Map<String, dynamic>?> getChatSession(String sessionId) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    final doc = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('chat_sessions')
        .doc(sessionId)
        .get();
    
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}
