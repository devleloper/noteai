import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatSession extends ChatEvent {
  final String recordingId;

  const LoadChatSession(this.recordingId);

  @override
  List<Object> get props => [recordingId];
}

class LoadMoreMessages extends ChatEvent {
  const LoadMoreMessages();
}

class ValidateConsistency extends ChatEvent {
  const ValidateConsistency();
}

class LoadInitialMessages extends ChatEvent {
  final String sessionId;

  const LoadInitialMessages(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class SendMessage extends ChatEvent {
  final String content;
  final String? model;

  const SendMessage(this.content, {this.model});

  @override
  List<Object?> get props => [content, model];
}

class RegenerateResponse extends ChatEvent {
  final String messageId;

  const RegenerateResponse(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class ChangeModel extends ChatEvent {
  final String model;

  const ChangeModel(this.model);

  @override
  List<Object> get props => [model];
}

class GenerateSummary extends ChatEvent {
  final String transcript;
  final String model;
  final String language;

  const GenerateSummary(this.transcript, this.model, this.language);

  @override
  List<Object> get props => [transcript, model, language];
}

class CheckSummaryStatus extends ChatEvent {
  final String recordingId;

  const CheckSummaryStatus(this.recordingId);

  @override
  List<Object> get props => [recordingId];
}

class GenerateSummaryOnDemand extends ChatEvent {
  final String recordingId;
  final String transcript;
  final String model;
  final String language;

  const GenerateSummaryOnDemand({
    required this.recordingId,
    required this.transcript,
    required this.model,
    required this.language,
  });

  @override
  List<Object> get props => [recordingId, transcript, model, language];
}

class CopyMessage extends ChatEvent {
  final String messageId;

  const CopyMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class DeleteMessage extends ChatEvent {
  final String messageId;

  const DeleteMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}

class RefreshSession extends ChatEvent {
  const RefreshSession();
}

class StartTyping extends ChatEvent {
  const StartTyping();
}

class StopTyping extends ChatEvent {
  const StopTyping();
}
