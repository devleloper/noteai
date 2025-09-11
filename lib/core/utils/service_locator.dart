import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart' as uuid_package;

import '../network/network_info.dart';
import '../../data/datasources/local/realm_datasource.dart';
import '../../data/datasources/local/audio_recording_service.dart';
import '../../data/datasources/local/background_recording_service.dart';
import '../../data/datasources/local/offline_task_queue.dart';
import '../../data/datasources/remote/firebase_datasource.dart';
import '../../data/datasources/remote/openai_datasource.dart';
import '../../data/datasources/remote/transcription_service.dart';
import '../../data/datasources/remote/ai_chat_service.dart';
import '../../data/repositories/recording_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/recording_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/recording/start_recording.dart';
import '../../domain/usecases/recording/stop_recording.dart';
import '../../domain/usecases/recording/get_recordings.dart';
import '../../domain/usecases/recording/delete_recording.dart';
import '../../domain/usecases/recording/update_recording.dart';
import '../../domain/usecases/transcription/start_transcription.dart';
import '../../domain/usecases/transcription/update_transcription.dart';
import '../../domain/usecases/auth/sign_in_with_google.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/update_user_preferences.dart';
import '../../domain/usecases/auth/get_user_preferences.dart';
import '../../presentation/features/settings/bloc/settings_bloc.dart';
import '../../domain/usecases/ai/transcribe_audio.dart';
import '../../domain/usecases/chat/create_session.dart';
import '../../domain/usecases/chat/send_message.dart';
import '../../domain/usecases/chat/get_chat_history.dart';
import '../../domain/usecases/chat/generate_summary.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External Dependencies
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingletonAsync(() => SharedPreferences.getInstance());
  sl.registerLazySingletonAsync(() => getApplicationDocumentsDirectory());
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // Data Sources
  sl.registerLazySingleton<RealmDataSource>(() => RealmDataSourceImpl());
  sl.registerLazySingleton<RealmDataSourceImpl>(() => sl<RealmDataSource>() as RealmDataSourceImpl);
  
  // Initialize Realm
  final realmDataSource = sl<RealmDataSource>();
  await realmDataSource.initialize();
  sl.registerLazySingleton<AudioRecordingService>(() => AudioRecordingService());
  sl.registerLazySingleton<BackgroundRecordingService>(() => BackgroundRecordingService());
  sl.registerLazySingleton<OfflineTaskQueue>(() => OfflineTaskQueue());
  sl.registerLazySingleton<FirebaseDataSource>(
    () => FirebaseDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<OpenAIDataSource>(() => OpenAIDataSourceImpl());
  sl.registerLazySingleton<TranscriptionService>(() => TranscriptionService());
  sl.registerLazySingleton<AIChatService>(() => AIChatService(sl()));
  
  // Repositories
  sl.registerLazySingleton<RecordingRepository>(
    () => RecordingRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      audioService: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<AIRepository>(
    () => AIRepositoryImpl(
      openAIDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => StartRecording(sl()));
  sl.registerLazySingleton(() => StopRecording(sl()));
  sl.registerLazySingleton(() => GetRecordings(sl()));
  sl.registerLazySingleton(() => DeleteRecording(sl()));
  sl.registerLazySingleton(() => UpdateRecording(sl()));
  sl.registerLazySingleton(() => StartTranscription(sl()));
  sl.registerLazySingleton(() => UpdateTranscription(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => UpdateUserPreferences(sl()));
  sl.registerLazySingleton(() => GetUserPreferences(sl()));
  sl.registerLazySingleton(() => TranscribeAudio(sl()));
  
  // Settings Bloc
  sl.registerFactory(() => SettingsBloc(
    getUserPreferences: sl(),
    updateUserPreferences: sl(),
  ));
  
  // Register ChatRepository and Chat Use Cases after Realm is initialized
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      realmDataSource: sl<RealmDataSource>(),
      aiService: sl(),
      firebaseDataSource: sl(),
      uuid: const uuid_package.Uuid(),
    ),
  );
  
  // Chat Use Cases
  sl.registerLazySingleton(() => CreateSession(sl()));
  sl.registerLazySingleton(() => SendMessage(sl()));
  sl.registerLazySingleton(() => GetChatHistory(sl()));
  sl.registerLazySingleton(() => GenerateSummary(sl()));
}
