import 'package:dartz/dartz.dart';
import '../usecase.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/recording_repository.dart';

class DeleteRecording implements UseCase<void, DeleteRecordingParams> {
  final RecordingRepository repository;

  DeleteRecording(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteRecordingParams params) async {
    return await repository.deleteRecording(params.recordingId);
  }
}

class DeleteRecordingParams {
  final String recordingId;

  DeleteRecordingParams({required this.recordingId});
}
