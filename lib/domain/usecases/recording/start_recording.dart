import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';
import '../../../core/errors/failures.dart';
import '../usecase.dart';

class StartRecording implements UseCase<Recording, StartRecordingParams> {
  final RecordingRepository repository;
  
  StartRecording(this.repository);
  
  @override
  Future<Either<Failure, Recording>> call(StartRecordingParams params) async {
    return await repository.startRecording(params.title);
  }
}

class StartRecordingParams extends Equatable {
  final String title;
  
  const StartRecordingParams({required this.title});
  
  @override
  List<Object> get props => [title];
}
