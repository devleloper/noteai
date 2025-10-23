import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart' as uuid_package;
import '../../../../core/utils/service_locator.dart';
import '../../../../domain/repositories/chat_repository.dart';
import '../../../../domain/usecases/chat/create_session.dart';
import '../../../../domain/usecases/chat/send_message.dart' as send_message_use_case;
import '../../../../domain/usecases/chat/get_chat_history.dart';
import '../../../../domain/usecases/chat/generate_summary.dart' as generate_summary_use_case;
import '../../../../domain/entities/chat_message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/model_selector.dart';
import '../widgets/typing_indicator.dart';
import '../../../widgets/sync/sync_status_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String recordingId;

  const ChatScreen({
    Key? key,
    required this.recordingId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc(
      createSession: sl<CreateSession>(),
      sendMessage: sl<send_message_use_case.SendMessage>(),
      getChatHistory: sl<GetChatHistory>(),
      generateSummary: sl<generate_summary_use_case.GenerateSummary>(),
      chatRepository: sl<ChatRepository>(),
      uuid: const uuid_package.Uuid(),
    );
    _chatBloc.add(LoadChatSession(widget.recordingId));
    
    // Auto-scroll to bottom when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _chatBloc.add(SendMessage(content));
    _messageController.clear();
    
    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onModelChanged(String model) {
    _chatBloc.add(ChangeModel(model));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatBloc>(
      create: (context) => _chatBloc,
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoaded) {
                return ModelSelector(
                  selectedModel: state.selectedModel,
                  onModelChanged: _onModelChanged,
                );
              }
              return const Text('Chat with AI');
            },
          ),
          actions: [
            const SyncStatusIndicator(showDetails: false),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is SummaryGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Summary generated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Auto-scroll to show the generated summary
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          } else if (state is ChatLoaded) {
            // Auto-scroll to bottom when new messages are received or typing starts
            final currentMessageCount = state.messages.length + (state.session.hasSummary ? 1 : 0);
            final shouldScroll = currentMessageCount > _lastMessageCount || state.isTyping;
            
            if (shouldScroll) {
              _lastMessageCount = currentMessageCount;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            }
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading chat',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _chatBloc.add(LoadChatSession(widget.recordingId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatLoaded) {
            // Create a list of all messages including summary as first message
            final List<ChatMessage> allMessages = [];
            
            // Add summary as first message if it exists
            if (state.session.hasSummary) {
              allMessages.add(ChatMessage(
                id: 'summary-${state.session.id}',
                sessionId: state.session.id,
                type: MessageType.ai,
                content: state.session.summary!,
                model: 'Summary',
                timestamp: state.session.createdAt,
                parentMessageId: null,
                metadata: {'isSummary': true},
              ));
            }
            
            // Add regular messages
            allMessages.addAll(state.messages);

            return Column(
              children: [
                // Messages list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: allMessages.length + (state.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show typing indicator at the end if typing
                      if (state.isTyping && index == allMessages.length) {
                        return const TypingIndicator();
                      }
                      
                      final message = allMessages[index];
                      final isSummary = message.metadata?['isSummary'] == true;
                      
                      return MessageBubble(
                        message: message,
                        onCopy: () {
                          // Show SnackBar directly without changing bloc state
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isSummary 
                                ? 'Summary copied to clipboard' 
                                : 'Message copied to clipboard'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        onRegenerate: isSummary ? () {} : () => _chatBloc.add(RegenerateResponse(message.id)),
                        onDelete: isSummary ? () {} : () => _chatBloc.add(DeleteMessage(message.id)),
                      );
                    },
                  ),
                ),

                // Message input
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<ChatBloc, ChatState>(
                        builder: (context, state) {
                          final isLoading = state is ChatLoaded && state.isGenerating;
                          return IconButton(
                            onPressed: isLoading ? null : _sendMessage,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.send),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
      ),
    );
  }
}
