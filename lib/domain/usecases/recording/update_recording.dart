import 'package:dartz/dartz.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';
import '../../../core/errors/failures.dart';
import '../usecase.dart';

class UpdateRecording implements UseCase<void, UpdateRecordingParams> {
  final RecordingRepository repository;

  UpdateRecording(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateRecordingParams params) async {
    return await repository.updateRecording(params.recording);
  }
}

class UpdateRecordingParams {
  final Recording recording;

  UpdateRecordingParams({required this.recording});
}
