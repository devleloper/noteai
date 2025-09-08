import 'package:dartz/dartz.dart';
import '../entities/recording.dart';
import '../../core/errors/failures.dart';

abstract class RecordingRepository {
  Future<Either<Failure, Recording>> startRecording(String title);
  Future<Either<Failure, void>> stopRecording(String recordingId);
  Future<Either<Failure, void>> pauseRecording(String recordingId);
  Future<Either<Failure, void>> resumeRecording(String recordingId);
  Future<Either<Failure, List<Recording>>> getRecordings();
  Future<Either<Failure, Recording>> getRecording(String id);
  Future<Either<Failure, void>> deleteRecording(String id);
  Future<Either<Failure, void>> updateRecording(Recording recording);
  Future<Either<Failure, void>> syncRecording(String id);
  Future<Either<Failure, List<Recording>>> getPendingSyncRecordings();
}
