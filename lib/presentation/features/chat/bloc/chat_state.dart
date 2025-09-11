import 'package:equatable/equatable.dart';
import '../../../../domain/entities/chat_session.dart';
import '../../../../domain/entities/chat_message.dart';

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

  const ChatLoaded({
    required this.session,
    required this.messages,
    required this.selectedModel,
    this.isGenerating = false,
    this.isGeneratingSummary = false,
    this.isTyping = false,
  });

  @override
  List<Object?> get props => [
        session,
        messages,
        selectedModel,
        isGenerating,
        isGeneratingSummary,
        isTyping,
      ];

  ChatLoaded copyWith({
    ChatSession? session,
    List<ChatMessage>? messages,
    String? selectedModel,
    bool? isGenerating,
    bool? isGeneratingSummary,
    bool? isTyping,
  }) {
    return ChatLoaded(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      selectedModel: selectedModel ?? this.selectedModel,
      isGenerating: isGenerating ?? this.isGenerating,
      isGeneratingSummary: isGeneratingSummary ?? this.isGeneratingSummary,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

class SummaryGenerated extends ChatState {
  final String summary;

  const SummaryGenerated(this.summary);

  @override
  List<Object> get props => [summary];
}

class MessageCopied extends ChatState {
  final String messageId;

  const MessageCopied(this.messageId);

  @override
  List<Object> get props => [messageId];
}
