import 'package:dartz/dartz.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../usecase.dart';

class GetUserPreferences implements UseCase<UserPreferences, NoParams> {
  final AuthRepository repository;

  GetUserPreferences(this.repository);

  @override
  Future<Either<Failure, UserPreferences>> call(NoParams params) async {
    return await repository.getCurrentUserPreferences();
  }
}
