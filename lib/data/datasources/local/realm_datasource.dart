import 'package:realm/realm.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/recording_model.dart';
import '../../models/realm_models.dart';
import '../../../core/errors/exceptions.dart';

abstract class RealmDataSource {
  Future<void> saveRecording(RecordingModel recording);
  Future<List<RecordingModel>> getRecordings();
  Future<RecordingModel?> getRecording(String id);
  Future<void> deleteRecording(String id);
  Future<void> updateRecording(RecordingModel recording);
  Future<void> initialize();
  Future<void> close();
}

class RealmDataSourceImpl implements RealmDataSource {
  Realm? _realm;
  
  @override
  Future<void> initialize() async {
    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final realmPath = '${appDir.path}/noteai.realm';
      
      // Initialize Realm with schema
      final config = Configuration.local([
        RecordingRealm.schema,
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
}