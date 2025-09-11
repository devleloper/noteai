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

  const GenerateSummary(this.transcript, this.model);

  @override
  List<Object> get props => [transcript, model];
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
