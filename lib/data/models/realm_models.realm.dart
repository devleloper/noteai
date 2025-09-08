// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_models.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class RecordingRealm extends _RecordingRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  RecordingRealm(
    String id,
    String title,
    String audioPath,
    int durationMs,
    DateTime createdAt,
    String status,
    double progress,
    bool isSynced, {
    DateTime? updatedAt,
    String? transcript,
    String? summary,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'audioPath', audioPath);
    RealmObjectBase.set(this, 'durationMs', durationMs);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'progress', progress);
    RealmObjectBase.set(this, 'transcript', transcript);
    RealmObjectBase.set(this, 'summary', summary);
    RealmObjectBase.set(this, 'isSynced', isSynced);
  }

  RecordingRealm._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String get audioPath =>
      RealmObjectBase.get<String>(this, 'audioPath') as String;
  @override
  set audioPath(String value) => RealmObjectBase.set(this, 'audioPath', value);

  @override
  int get durationMs => RealmObjectBase.get<int>(this, 'durationMs') as int;
  @override
  set durationMs(int value) => RealmObjectBase.set(this, 'durationMs', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime? get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime?;
  @override
  set updatedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  double get progress =>
      RealmObjectBase.get<double>(this, 'progress') as double;
  @override
  set progress(double value) => RealmObjectBase.set(this, 'progress', value);

  @override
  String? get transcript =>
      RealmObjectBase.get<String>(this, 'transcript') as String?;
  @override
  set transcript(String? value) =>
      RealmObjectBase.set(this, 'transcript', value);

  @override
  String? get summary =>
      RealmObjectBase.get<String>(this, 'summary') as String?;
  @override
  set summary(String? value) => RealmObjectBase.set(this, 'summary', value);

  @override
  bool get isSynced => RealmObjectBase.get<bool>(this, 'isSynced') as bool;
  @override
  set isSynced(bool value) => RealmObjectBase.set(this, 'isSynced', value);

  @override
  Stream<RealmObjectChanges<RecordingRealm>> get changes =>
      RealmObjectBase.getChanges<RecordingRealm>(this);

  @override
  Stream<RealmObjectChanges<RecordingRealm>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<RecordingRealm>(this, keyPaths);

  @override
  RecordingRealm freeze() => RealmObjectBase.freezeObject<RecordingRealm>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'audioPath': audioPath.toEJson(),
      'durationMs': durationMs.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
      'status': status.toEJson(),
      'progress': progress.toEJson(),
      'transcript': transcript.toEJson(),
      'summary': summary.toEJson(),
      'isSynced': isSynced.toEJson(),
    };
  }

  static EJsonValue _toEJson(RecordingRealm value) => value.toEJson();
  static RecordingRealm _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'title': EJsonValue title,
        'audioPath': EJsonValue audioPath,
        'durationMs': EJsonValue durationMs,
        'createdAt': EJsonValue createdAt,
        'status': EJsonValue status,
        'progress': EJsonValue progress,
        'isSynced': EJsonValue isSynced,
      } =>
        RecordingRealm(
          fromEJson(id),
          fromEJson(title),
          fromEJson(audioPath),
          fromEJson(durationMs),
          fromEJson(createdAt),
          fromEJson(status),
          fromEJson(progress),
          fromEJson(isSynced),
          updatedAt: fromEJson(ejson['updatedAt']),
          transcript: fromEJson(ejson['transcript']),
          summary: fromEJson(ejson['summary']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(RecordingRealm._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      RecordingRealm,
      'RecordingRealm',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('title', RealmPropertyType.string),
        SchemaProperty('audioPath', RealmPropertyType.string),
        SchemaProperty('durationMs', RealmPropertyType.int),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
        SchemaProperty(
          'updatedAt',
          RealmPropertyType.timestamp,
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string),
        SchemaProperty('progress', RealmPropertyType.double),
        SchemaProperty('transcript', RealmPropertyType.string, optional: true),
        SchemaProperty('summary', RealmPropertyType.string, optional: true),
        SchemaProperty('isSynced', RealmPropertyType.bool),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
