import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class RecordingFailure extends Failure {
  const RecordingFailure(super.message);
}

class AITranscriptionFailure extends Failure {
  const AITranscriptionFailure(super.message);
}

class AISummaryFailure extends Failure {
  const AISummaryFailure(super.message);
}

class AIChatFailure extends Failure {
  const AIChatFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AIFailure extends Failure {
  const AIFailure(super.message);
}
