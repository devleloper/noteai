import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/recording_repository.dart';
import '../../../core/errors/failures.dart';
import '../usecase.dart';

class StopRecording implements UseCase<void, StopRecordingParams> {
  final RecordingRepository repository;
  
  StopRecording(this.repository);
  
  @override
  Future<Either<Failure, void>> call(StopRecordingParams params) async {
    return await repository.stopRecording(params.recordingId);
  }
}

class StopRecordingParams extends Equatable {
  final String recordingId;
  
  const StopRecordingParams({required this.recordingId});
  
  @override
  List<Object> get props => [recordingId];
}
