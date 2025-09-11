import 'package:dartz/dartz.dart';
import '../entities/recording.dart';
import '../../core/errors/failures.dart';

abstract class RecordingRepository {
  Future<Either<Failure, Recording>> startRecording(String title);
  Future<Either<Failure, void>> stopRecording(String recordingId);
  Future<Either<Failure, List<Recording>>> getRecordings();
  Future<Either<Failure, Recording>> getRecording(String id);
  Future<Either<Failure, void>> deleteRecording(String id);
  Future<Either<Failure, void>> updateRecording(Recording recording);
  Future<Either<Failure, void>> syncRecording(String id);
  Future<Either<Failure, List<Recording>>> getPendingSyncRecordings();
  
  // Transcription methods
  Future<Either<Failure, Recording>> startTranscription(String recordingId);
  Future<Either<Failure, Recording>> updateTranscription(
    String recordingId,
    String? transcript,
    TranscriptionStatus transcriptionStatus,
    String? transcriptionError,
  );
  Future<Either<Failure, List<Recording>>> getPendingTranscriptions();
}
