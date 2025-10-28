import 'package:equatable/equatable.dart';
import '../../../../domain/entities/chat_session.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../../domain/entities/summarization_state.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final ChatSession session;
  final List<ChatMessage> messages;
  final String selectedModel;
  final bool isGenerating;
  final bool isGeneratingSummary;
  final bool isTyping;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final int totalMessages;
  final bool isConsistencyValid;
  final SummarizationState? summarizationState;

  const ChatLoaded({
    required this.session,
    required this.messages,
    required this.selectedModel,
    this.isGenerating = false,
    this.isGeneratingSummary = false,
    this.isTyping = false,
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.totalMessages = 0,
    this.isConsistencyValid = true,
    this.summarizationState,
  });

  @override
  List<Object?> get props => [
        session,
        messages,
        selectedModel,
        isGenerating,
        isGeneratingSummary,
        isTyping,
        isLoadingMore,
        hasMoreMessages,
        totalMessages,
        isConsistencyValid,
        summarizationState,
      ];

  ChatLoaded copyWith({
    ChatSession? session,
    List<ChatMessage>? messages,
    String? selectedModel,
    bool? isGenerating,
    bool? isGeneratingSummary,
    bool? isTyping,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    int? totalMessages,
    bool? isConsistencyValid,
    SummarizationState? summarizationState,
  }) {
    return ChatLoaded(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      selectedModel: selectedModel ?? this.selectedModel,
      isGenerating: isGenerating ?? this.isGenerating,
      isGeneratingSummary: isGeneratingSummary ?? this.isGeneratingSummary,
      isTyping: isTyping ?? this.isTyping,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      totalMessages: totalMessages ?? this.totalMessages,
      isConsistencyValid: isConsistencyValid ?? this.isConsistencyValid,
      summarizationState: summarizationState ?? this.summarizationState,
    );
  }
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class SummaryGenerating extends ChatState {
  final String recordingId;
  final SummarizationState summarizationState;

  const SummaryGenerating({
    required this.recordingId,
    required this.summarizationState,
  });

  @override
  List<Object> get props => [recordingId, summarizationState];
}

class SummaryGenerated extends ChatState {
  final String summary;
  final SummarizationState summarizationState;

  const SummaryGenerated({
    required this.summary,
    required this.summarizationState,
  });

  @override
  List<Object> get props => [summary, summarizationState];
}

class SummaryFailed extends ChatState {
  final String error;
  final SummarizationState summarizationState;

  const SummaryFailed({
    required this.error,
    required this.summarizationState,
  });

  @override
  List<Object> get props => [error, summarizationState];
}

class MessageCopied extends ChatState {
  final String messageId;

  const MessageCopied(this.messageId);

  @override
  List<Object> get props => [messageId];
}
