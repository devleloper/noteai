import 'package:dartz/dartz.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../usecase.dart';

class UpdateUserPreferences implements UseCase<void, UpdateUserPreferencesParams> {
  final AuthRepository repository;

  UpdateUserPreferences(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserPreferencesParams params) async {
    return await repository.updateUserPreferences(params.preferences);
  }
}

class UpdateUserPreferencesParams {
  final UserPreferences preferences;

  UpdateUserPreferencesParams({required this.preferences});
}
