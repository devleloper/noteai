import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart' as uuid_package;
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/chat_session.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../../domain/repositories/chat_repository.dart';
import '../../../../domain/usecases/chat/create_session.dart';
import '../../../../domain/usecases/chat/send_message.dart' as send_message_use_case;
import '../../../../domain/usecases/chat/get_chat_history.dart';
import '../../../../domain/usecases/chat/generate_summary.dart' as generate_summary_use_case;
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final CreateSession _createSession;
  final send_message_use_case.SendMessage _sendMessage;
  final GetChatHistory _getChatHistory;
  final generate_summary_use_case.GenerateSummary _generateSummary;
  final ChatRepository _chatRepository;
  final uuid_package.Uuid _uuid;

  ChatBloc({
    required CreateSession createSession,
    required send_message_use_case.SendMessage sendMessage,
    required GetChatHistory getChatHistory,
    required generate_summary_use_case.GenerateSummary generateSummary,
    required ChatRepository chatRepository,
    required uuid_package.Uuid uuid,
  }) : _createSession = createSession,
       _sendMessage = sendMessage,
       _getChatHistory = getChatHistory,
       _generateSummary = generateSummary,
       _chatRepository = chatRepository,
       _uuid = uuid,
       super(const ChatInitial()) {
    
    on<LoadChatSession>(_onLoadChatSession);
    on<SendMessage>(_onSendMessage);
    on<RegenerateResponse>(_onRegenerateResponse);
    on<ChangeModel>(_onChangeModel);
    on<GenerateSummary>(_onGenerateSummary);
    on<CopyMessage>(_onCopyMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<RefreshSession>(_onRefreshSession);
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);
  }

  void _onLoadChatSession(
    LoadChatSession event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    try {
      // Try to get existing session
      final sessionResult = await _chatRepository.getSessionByRecordingId(event.recordingId);
      
      if (sessionResult.isRight()) {
        final session = sessionResult.getOrElse(() => throw Exception('Failed to get session'));
        final messagesResult = await _getChatHistory(session.id);
        
        if (messagesResult.isRight()) {
          final messages = messagesResult.getOrElse(() => throw Exception('Failed to get messages'));
          emit(ChatLoaded(
            session: session,
            messages: messages,
            selectedModel: session.defaultModel,
          ));
          return;
        }
      }

      // Create new session if none exists
      final createResult = await _createSession(event.recordingId);
      createResult.fold(
        (failure) => emit(ChatError(failure.message ?? 'Failed to create chat session')),
        (session) => emit(ChatLoaded(
          session: session,
          messages: session.messages,
          selectedModel: session.defaultModel,
        )),
      );
    } catch (e) {
      emit(ChatError('Failed to load chat session: $e'));
    }
  }

  void _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    
    // First, add the user message immediately to the UI
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      sessionId: currentState.session.id,
      type: MessageType.user,
      content: event.content,
      model: event.model ?? currentState.selectedModel,
      timestamp: DateTime.now(),
      parentMessageId: null,
    );
    
    final updatedMessages = [...currentState.messages, userMessage];
    emit(currentState.copyWith(
      messages: updatedMessages,
      isGenerating: true,
      isTyping: true,
    ));

    try {
      final params = SendMessageParams(
        sessionId: currentState.session.id,
        content: event.content,
        model: event.model ?? currentState.selectedModel,
      );

      final result = await _sendMessage(params);
      result.fold(
        (failure) {
          emit(ChatError(failure.message ?? 'Failed to send message'));
        },
        (message) {
          // Reload messages to get updated list with AI response
          _addEvent(RefreshSession());
        },
      );
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
    }
  }

  void _onRegenerateResponse(
    RegenerateResponse event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    emit(currentState.copyWith(isGenerating: true));

    try {
      final params = RegenerateMessageParams(
        messageId: event.messageId,
        sessionId: currentState.session.id,
        model: currentState.selectedModel,
      );

      final result = await _chatRepository.regenerateMessage(params);
      result.fold(
        (failure) => emit(ChatError(failure.message ?? 'Failed to regenerate message')),
        (message) {
          // Reload messages to get updated list
          _addEvent(RefreshSession());
        },
      );
    } catch (e) {
      emit(ChatError('Failed to regenerate message: $e'));
    }
  }

  void _onChangeModel(
    ChangeModel event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    emit(currentState.copyWith(selectedModel: event.model));
  }

  void _onGenerateSummary(
    GenerateSummary event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    emit(currentState.copyWith(isGeneratingSummary: true));

    try {
      final params = GenerateSummaryParams(
        recordingId: currentState.session.recordingId,
        transcript: event.transcript,
        model: event.model,
      );

      final result = await _generateSummary(params);
      result.fold(
        (failure) => emit(ChatError(failure.message ?? 'Failed to generate summary')),
        (summary) {
          emit(SummaryGenerated(summary));
          // Reload session to get updated summary
          _addEvent(RefreshSession());
        },
      );
    } catch (e) {
      emit(ChatError('Failed to generate summary: $e'));
    }
  }

  void _onCopyMessage(
    CopyMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final message = currentState.messages.firstWhere(
      (m) => m.id == event.messageId,
      orElse: () => throw Exception('Message not found'),
    );

    // In a real implementation, you would copy to clipboard here
    // For now, just emit the copied state
    emit(MessageCopied(event.messageId));
    
    // Return to loaded state after a brief moment
    await Future.delayed(const Duration(milliseconds: 500));
    emit(currentState);
  }

  void _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    try {
      final result = await _chatRepository.deleteMessage(event.messageId);
      result.fold(
        (failure) => emit(ChatError(failure.message ?? 'Failed to delete message')),
        (_) {
          // Reload messages to get updated list
          _addEvent(RefreshSession());
        },
      );
    } catch (e) {
      emit(ChatError('Failed to delete message: $e'));
    }
  }

  void _onRefreshSession(
    RefreshSession event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;

    try {
      final sessionResult = await _chatRepository.getSession(currentState.session.id);
      final messagesResult = await _getChatHistory(currentState.session.id);

      if (sessionResult.isRight() && messagesResult.isRight()) {
        final session = sessionResult.getOrElse(() => throw Exception('Failed to get session'));
        final messages = messagesResult.getOrElse(() => throw Exception('Failed to get messages'));
        
        emit(ChatLoaded(
          session: session,
          messages: messages,
          selectedModel: currentState.selectedModel,
          isGenerating: false,
          isGeneratingSummary: false,
          isTyping: false,
        ));
      }
    } catch (e) {
      emit(ChatError('Failed to refresh session: $e'));
    }
  }

  void _onStartTyping(
    StartTyping event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    emit(currentState.copyWith(isTyping: true));
  }

  void _onStopTyping(
    StopTyping event,
    Emitter<ChatState> emit,
  ) {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    emit(currentState.copyWith(isTyping: false));
  }

  // Helper method to add events
  void _addEvent(ChatEvent event) {
    add(event);
  }
}
