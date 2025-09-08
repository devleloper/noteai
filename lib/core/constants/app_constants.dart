class AppConstants {
  // API Configuration
  static const String openAIApiKey = 'OPENAI_API_KEY';
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String whisperModel = 'whisper-1';
  static const String gptModel = 'gpt-3.5-turbo';
  
  // Audio Configuration
  static const int maxChunkSizeMB = 25; // OpenAI limit
  static const int chunkOverlapSeconds = 2;
  static const int maxRecordingDurationMinutes = 60;
  
  // Database Configuration
  static const String realmSchemaVersion = '1.0.0';
  static const String recordingsCollection = 'recordings';
  static const String transcriptsCollection = 'transcripts';
  static const String summariesCollection = 'summaries';
  
  // UI Configuration
  static const double cardPadding = 16.0;
  static const double cardMargin = 8.0;
  static const double borderRadius = 12.0;
  
  // Sync Configuration
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 30);
  
  // Chat Configuration
  static const int maxContextMessages = 10;
  static const int maxTokens = 500;
}
