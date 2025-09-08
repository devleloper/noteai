import 'package:equatable/equatable.dart';

class Summary extends Equatable {
  final String id;
  final String recordingId;
  final String content;
  final List<String> keyPoints;
  final List<String> actionItems;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSynced;
  
  const Summary({
    required this.id,
    required this.recordingId,
    required this.content,
    required this.keyPoints,
    required this.actionItems,
    required this.createdAt,
    this.updatedAt,
    required this.isSynced,
  });
  
  @override
  List<Object?> get props => [
    id,
    recordingId,
    content,
    keyPoints,
    actionItems,
    createdAt,
    updatedAt,
    isSynced,
  ];
  
  Summary copyWith({
    String? id,
    String? recordingId,
    String? content,
    List<String>? keyPoints,
    List<String>? actionItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Summary(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      content: content ?? this.content,
      keyPoints: keyPoints ?? this.keyPoints,
      actionItems: actionItems ?? this.actionItems,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
