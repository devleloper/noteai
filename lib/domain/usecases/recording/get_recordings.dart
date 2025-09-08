import 'package:dartz/dartz.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';
import '../../../core/errors/failures.dart';
import '../usecase.dart';

class GetRecordings implements UseCase<List<Recording>, NoParams> {
  final RecordingRepository repository;
  
  GetRecordings(this.repository);
  
  @override
  Future<Either<Failure, List<Recording>>> call(NoParams params) async {
    return await repository.getRecordings();
  }
}
