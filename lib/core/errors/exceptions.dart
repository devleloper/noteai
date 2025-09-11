class ServerException implements Exception {
  final String message;
  
  const ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class RecordingException implements Exception {
  final String message;
  
  const RecordingException(this.message);
  
  @override
  String toString() => 'RecordingException: $message';
}

class AITranscriptionException implements Exception {
  final String message;
  
  const AITranscriptionException(this.message);
  
  @override
  String toString() => 'AITranscriptionException: $message';
}

class AIException implements Exception {
  final String message;
  
  const AIException(this.message);
  
  @override
  String toString() => 'AIException: $message';
}

class AISummaryException implements Exception {
  final String message;
  
  const AISummaryException(this.message);
  
  @override
  String toString() => 'AISummaryException: $message';
}

class TranscriptionException implements Exception {
  final String message;
  
  const TranscriptionException(this.message);
  
  @override
  String toString() => 'TranscriptionException: $message';
}
