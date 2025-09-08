import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../entities/transcript.dart';
import '../../repositories/ai_repository.dart';
import '../../../core/errors/failures.dart';
import '../usecase.dart';

class TranscribeAudio implements UseCase<Transcript, TranscribeAudioParams> {
  final AIRepository repository;
  
  TranscribeAudio(this.repository);
  
  @override
  Future<Either<Failure, Transcript>> call(TranscribeAudioParams params) async {
    return await repository.transcribeAudio(params.audioPath);
  }
}

class TranscribeAudioParams extends Equatable {
  final String audioPath;
  
  const TranscribeAudioParams({required this.audioPath});
  
  @override
  List<Object> get props => [audioPath];
}
