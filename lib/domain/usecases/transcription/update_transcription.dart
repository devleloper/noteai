import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../usecase.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';

class UpdateTranscription implements UseCase<Recording, UpdateTranscriptionParams> {
  final RecordingRepository repository;
  
  UpdateTranscription(this.repository);
  
  @override
  Future<Either<Failure, Recording>> call(UpdateTranscriptionParams params) async {
    return await repository.updateTranscription(
      params.recordingId,
      params.transcript,
      params.transcriptionStatus,
      params.transcriptionError,
    );
  }
}

class UpdateTranscriptionParams {
  final String recordingId;
  final String? transcript;
  final TranscriptionStatus transcriptionStatus;
  final String? transcriptionError;
  
  UpdateTranscriptionParams({
    required this.recordingId,
    this.transcript,
    required this.transcriptionStatus,
    this.transcriptionError,
  });
}
