import 'package:equatable/equatable.dart';

enum SummarizationStatus {
  pending,
  generating,
  completed,
  failed,
}

class SummarizationState extends Equatable {
  final String recordingId;
  final SummarizationStatus status;
  final int retryAttempts;
  final String? error;
  final DateTime? lastAttempt;
  final String? generatedSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SummarizationState({
    required this.recordingId,
    required this.status,
    required this.retryAttempts,
    this.error,
    this.lastAttempt,
    this.generatedSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        recordingId,
        status,
        retryAttempts,
        error,
        lastAttempt,
        generatedSummary,
        createdAt,
        updatedAt,
      ];

  SummarizationState copyWith({
    String? recordingId,
    SummarizationStatus? status,
    int? retryAttempts,
    String? error,
    DateTime? lastAttempt,
    String? generatedSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SummarizationState(
      recordingId: recordingId ?? this.recordingId,
      status: status ?? this.status,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      error: error ?? this.error,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      generatedSummary: generatedSummary ?? this.generatedSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCompleted => status == SummarizationStatus.completed;
  bool get isGenerating => status == SummarizationStatus.generating;
  bool get isFailed => status == SummarizationStatus.failed;
  bool get isPending => status == SummarizationStatus.pending;
  bool get hasSummary => generatedSummary != null && generatedSummary!.isNotEmpty;
}