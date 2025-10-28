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
    bool isSynced,
    String transcriptionStatus, {
    DateTime? updatedAt,
    String? transcript,
    String? summary,
    DateTime? transcriptionCompletedAt,
    String? transcriptionError,
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
    RealmObjectBase.set(this, 'transcriptionStatus', transcriptionStatus);
    RealmObjectBase.set(
      this,
      'transcriptionCompletedAt',
      transcriptionCompletedAt,
    );
    RealmObjectBase.set(this, 'transcriptionError', transcriptionError);
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
  String get transcriptionStatus =>
      RealmObjectBase.get<String>(this, 'transcriptionStatus') as String;
  @override
  set transcriptionStatus(String value) =>
      RealmObjectBase.set(this, 'transcriptionStatus', value);

  @override
  DateTime? get transcriptionCompletedAt =>
      RealmObjectBase.get<DateTime>(this, 'transcriptionCompletedAt')
          as DateTime?;
  @override
  set transcriptionCompletedAt(DateTime? value) =>
      RealmObjectBase.set(this, 'transcriptionCompletedAt', value);

  @override
  String? get transcriptionError =>
      RealmObjectBase.get<String>(this, 'transcriptionError') as String?;
  @override
  set transcriptionError(String? value) =>
      RealmObjectBase.set(this, 'transcriptionError', value);

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
      'transcriptionStatus': transcriptionStatus.toEJson(),
      'transcriptionCompletedAt': transcriptionCompletedAt.toEJson(),
      'transcriptionError': transcriptionError.toEJson(),
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
        'transcriptionStatus': EJsonValue transcriptionStatus,
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
          fromEJson(transcriptionStatus),
          updatedAt: fromEJson(ejson['updatedAt']),
          transcript: fromEJson(ejson['transcript']),
          summary: fromEJson(ejson['summary']),
          transcriptionCompletedAt: fromEJson(
            ejson['transcriptionCompletedAt'],
          ),
          transcriptionError: fromEJson(ejson['transcriptionError']),
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
        SchemaProperty('transcriptionStatus', RealmPropertyType.string),
        SchemaProperty(
          'transcriptionCompletedAt',
          RealmPropertyType.timestamp,
          optional: true,
        ),
        SchemaProperty(
          'transcriptionError',
          RealmPropertyType.string,
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ChatMessageRealm extends _ChatMessageRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  ChatMessageRealm(
    String id,
    String sessionId,
    String type,
    String content,
    DateTime timestamp, {
    String? model,
    String? parentMessageId,
    String? metadata,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'sessionId', sessionId);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'content', content);
    RealmObjectBase.set(this, 'model', model);
    RealmObjectBase.set(this, 'timestamp', timestamp);
    RealmObjectBase.set(this, 'parentMessageId', parentMessageId);
    RealmObjectBase.set(this, 'metadata', metadata);
  }

  ChatMessageRealm._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get sessionId =>
      RealmObjectBase.get<String>(this, 'sessionId') as String;
  @override
  set sessionId(String value) => RealmObjectBase.set(this, 'sessionId', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  String get content => RealmObjectBase.get<String>(this, 'content') as String;
  @override
  set content(String value) => RealmObjectBase.set(this, 'content', value);

  @override
  String? get model => RealmObjectBase.get<String>(this, 'model') as String?;
  @override
  set model(String? value) => RealmObjectBase.set(this, 'model', value);

  @override
  DateTime get timestamp =>
      RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) =>
      RealmObjectBase.set(this, 'timestamp', value);

  @override
  String? get parentMessageId =>
      RealmObjectBase.get<String>(this, 'parentMessageId') as String?;
  @override
  set parentMessageId(String? value) =>
      RealmObjectBase.set(this, 'parentMessageId', value);

  @override
  String? get metadata =>
      RealmObjectBase.get<String>(this, 'metadata') as String?;
  @override
  set metadata(String? value) => RealmObjectBase.set(this, 'metadata', value);

  @override
  Stream<RealmObjectChanges<ChatMessageRealm>> get changes =>
      RealmObjectBase.getChanges<ChatMessageRealm>(this);

  @override
  Stream<RealmObjectChanges<ChatMessageRealm>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<ChatMessageRealm>(this, keyPaths);

  @override
  ChatMessageRealm freeze() =>
      RealmObjectBase.freezeObject<ChatMessageRealm>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'sessionId': sessionId.toEJson(),
      'type': type.toEJson(),
      'content': content.toEJson(),
      'model': model.toEJson(),
      'timestamp': timestamp.toEJson(),
      'parentMessageId': parentMessageId.toEJson(),
      'metadata': metadata.toEJson(),
    };
  }

  static EJsonValue _toEJson(ChatMessageRealm value) => value.toEJson();
  static ChatMessageRealm _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'sessionId': EJsonValue sessionId,
        'type': EJsonValue type,
        'content': EJsonValue content,
        'timestamp': EJsonValue timestamp,
      } =>
        ChatMessageRealm(
          fromEJson(id),
          fromEJson(sessionId),
          fromEJson(type),
          fromEJson(content),
          fromEJson(timestamp),
          model: fromEJson(ejson['model']),
          parentMessageId: fromEJson(ejson['parentMessageId']),
          metadata: fromEJson(ejson['metadata']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ChatMessageRealm._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      ChatMessageRealm,
      'ChatMessageRealm',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('sessionId', RealmPropertyType.string),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('content', RealmPropertyType.string),
        SchemaProperty('model', RealmPropertyType.string, optional: true),
        SchemaProperty('timestamp', RealmPropertyType.timestamp),
        SchemaProperty(
          'parentMessageId',
          RealmPropertyType.string,
          optional: true,
        ),
        SchemaProperty('metadata', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ChatSessionRealm extends _ChatSessionRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  ChatSessionRealm(
    String id,
    String recordingId,
    String defaultModel,
    DateTime createdAt,
    DateTime updatedAt, {
    String? summary,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'recordingId', recordingId);
    RealmObjectBase.set(this, 'summary', summary);
    RealmObjectBase.set(this, 'defaultModel', defaultModel);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  ChatSessionRealm._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get recordingId =>
      RealmObjectBase.get<String>(this, 'recordingId') as String;
  @override
  set recordingId(String value) =>
      RealmObjectBase.set(this, 'recordingId', value);

  @override
  String? get summary =>
      RealmObjectBase.get<String>(this, 'summary') as String?;
  @override
  set summary(String? value) => RealmObjectBase.set(this, 'summary', value);

  @override
  String get defaultModel =>
      RealmObjectBase.get<String>(this, 'defaultModel') as String;
  @override
  set defaultModel(String value) =>
      RealmObjectBase.set(this, 'defaultModel', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<ChatSessionRealm>> get changes =>
      RealmObjectBase.getChanges<ChatSessionRealm>(this);

  @override
  Stream<RealmObjectChanges<ChatSessionRealm>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<ChatSessionRealm>(this, keyPaths);

  @override
  ChatSessionRealm freeze() =>
      RealmObjectBase.freezeObject<ChatSessionRealm>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'recordingId': recordingId.toEJson(),
      'summary': summary.toEJson(),
      'defaultModel': defaultModel.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(ChatSessionRealm value) => value.toEJson();
  static ChatSessionRealm _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'recordingId': EJsonValue recordingId,
        'defaultModel': EJsonValue defaultModel,
        'createdAt': EJsonValue createdAt,
        'updatedAt': EJsonValue updatedAt,
      } =>
        ChatSessionRealm(
          fromEJson(id),
          fromEJson(recordingId),
          fromEJson(defaultModel),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          summary: fromEJson(ejson['summary']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ChatSessionRealm._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      ChatSessionRealm,
      'ChatSessionRealm',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('recordingId', RealmPropertyType.string),
        SchemaProperty('summary', RealmPropertyType.string, optional: true),
        SchemaProperty('defaultModel', RealmPropertyType.string),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
        SchemaProperty('updatedAt', RealmPropertyType.timestamp),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class SummarizationStateRealm extends _SummarizationStateRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  SummarizationStateRealm(
    String recordingId,
    String status,
    int retryAttempts,
    DateTime createdAt,
    DateTime updatedAt, {
    String? error,
    DateTime? lastAttempt,
    String? generatedSummary,
  }) {
    RealmObjectBase.set(this, 'recordingId', recordingId);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'retryAttempts', retryAttempts);
    RealmObjectBase.set(this, 'error', error);
    RealmObjectBase.set(this, 'lastAttempt', lastAttempt);
    RealmObjectBase.set(this, 'generatedSummary', generatedSummary);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  SummarizationStateRealm._();

  @override
  String get recordingId =>
      RealmObjectBase.get<String>(this, 'recordingId') as String;
  @override
  set recordingId(String value) =>
      RealmObjectBase.set(this, 'recordingId', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  int get retryAttempts =>
      RealmObjectBase.get<int>(this, 'retryAttempts') as int;
  @override
  set retryAttempts(int value) =>
      RealmObjectBase.set(this, 'retryAttempts', value);

  @override
  String? get error => RealmObjectBase.get<String>(this, 'error') as String?;
  @override
  set error(String? value) => RealmObjectBase.set(this, 'error', value);

  @override
  DateTime? get lastAttempt =>
      RealmObjectBase.get<DateTime>(this, 'lastAttempt') as DateTime?;
  @override
  set lastAttempt(DateTime? value) =>
      RealmObjectBase.set(this, 'lastAttempt', value);

  @override
  String? get generatedSummary =>
      RealmObjectBase.get<String>(this, 'generatedSummary') as String?;
  @override
  set generatedSummary(String? value) =>
      RealmObjectBase.set(this, 'generatedSummary', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<SummarizationStateRealm>> get changes =>
      RealmObjectBase.getChanges<SummarizationStateRealm>(this);

  @override
  Stream<RealmObjectChanges<SummarizationStateRealm>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SummarizationStateRealm>(this, keyPaths);

  @override
  SummarizationStateRealm freeze() =>
      RealmObjectBase.freezeObject<SummarizationStateRealm>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'recordingId': recordingId.toEJson(),
      'status': status.toEJson(),
      'retryAttempts': retryAttempts.toEJson(),
      'error': error.toEJson(),
      'lastAttempt': lastAttempt.toEJson(),
      'generatedSummary': generatedSummary.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(SummarizationStateRealm value) => value.toEJson();
  static SummarizationStateRealm _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'recordingId': EJsonValue recordingId,
        'status': EJsonValue status,
        'retryAttempts': EJsonValue retryAttempts,
        'createdAt': EJsonValue createdAt,
        'updatedAt': EJsonValue updatedAt,
      } =>
        SummarizationStateRealm(
          fromEJson(recordingId),
          fromEJson(status),
          fromEJson(retryAttempts),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          error: fromEJson(ejson['error']),
          lastAttempt: fromEJson(ejson['lastAttempt']),
          generatedSummary: fromEJson(ejson['generatedSummary']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SummarizationStateRealm._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      SummarizationStateRealm,
      'SummarizationStateRealm',
      [
        SchemaProperty(
          'recordingId',
          RealmPropertyType.string,
          primaryKey: true,
        ),
        SchemaProperty('status', RealmPropertyType.string),
        SchemaProperty('retryAttempts', RealmPropertyType.int),
        SchemaProperty('error', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'lastAttempt',
          RealmPropertyType.timestamp,
          optional: true,
        ),
        SchemaProperty(
          'generatedSummary',
          RealmPropertyType.string,
          optional: true,
        ),
        SchemaProperty('createdAt', RealmPropertyType.timestamp),
        SchemaProperty('updatedAt', RealmPropertyType.timestamp),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
