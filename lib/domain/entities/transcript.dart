import 'package:equatable/equatable.dart';

class Transcript extends Equatable {
  final String id;
  final String recordingId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  
  const Transcript({
    required this.id,
    required this.recordingId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    required this.isSynced,
  });
  
  @override
  List<Object?> get props => [
    id,
    recordingId,
    content,
    createdAt,
    updatedAt,
    isSynced,
  ];
  
  Transcript copyWith({
    String? id,
    String? recordingId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Transcript(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
