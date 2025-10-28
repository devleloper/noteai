import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/chat_repository.dart';

class GenerateSummary {
  final ChatRepository repository;

  GenerateSummary(this.repository);

  Future<Either<Failure, String>> call(GenerateSummaryParams params) async {
    return await repository.generateSummary(params);
  }
}
