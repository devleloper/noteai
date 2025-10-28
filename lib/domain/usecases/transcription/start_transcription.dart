import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../usecase.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';

class StartTranscription implements UseCase<Recording, StartTranscriptionParams> {
  final RecordingRepository repository;
  
  StartTranscription(this.repository);
  
  @override
  Future<Either<Failure, Recording>> call(StartTranscriptionParams params) async {
    return await repository.startTranscription(params.recordingId);
  }
}

class StartTranscriptionParams {
  final String recordingId;
  
  StartTranscriptionParams({required this.recordingId});
}
