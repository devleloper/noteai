import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../usecase.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';

class GetTranscription implements UseCase<Recording, GetTranscriptionParams> {
  final RecordingRepository repository;
  
  GetTranscription(this.repository);
  
  @override
  Future<Either<Failure, Recording>> call(GetTranscriptionParams params) async {
    return await repository.getRecording(params.recordingId);
  }
}

class GetTranscriptionParams {
  final String recordingId;
  
  GetTranscriptionParams({required this.recordingId});
}
