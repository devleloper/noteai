import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API Configuration
  static String get openAIApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAIOrgId => dotenv.env['OPENAI_ORG_ID'] ?? '';
  static const String openAIBaseUrl = 'https://api.openai.com/v1';
  static const String whisperModel = 'whisper-1';
  static const String gptModel = 'gpt-4o';
  
  // Audio Configuration
  static const int maxChunkSizeMB = 25; // OpenAI limit
  static const int chunkOverlapSeconds = 2;
  static int get maxRecordingDurationMinutes => 
    int.tryParse(dotenv.env['MAX_RECORDING_DURATION_MINUTES'] ?? '120') ?? 120;
  
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
  static int get maxTokens => 
    int.tryParse(dotenv.env['MAX_TRANSCRIPT_LENGTH'] ?? '500') ?? 500;
  
  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'NoteAI';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static bool get mockAIResponses => dotenv.env['MOCK_AI_RESPONSES']?.toLowerCase() == 'true';
  static bool get enableDebugLogging => dotenv.env['ENABLE_DEBUG_LOGGING']?.toLowerCase() == 'true';
  
  // Storage Configuration
  static int get maxLocalStorageMB => 
    int.tryParse(dotenv.env['MAX_LOCAL_STORAGE_MB'] ?? '1000') ?? 1000;
  static int get autoSyncIntervalMinutes => 
    int.tryParse(dotenv.env['AUTO_SYNC_INTERVAL_MINUTES'] ?? '30') ?? 30;
}
