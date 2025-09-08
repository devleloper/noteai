import 'package:dartz/dartz.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../../core/errors/failures.dart';
import '../usecase.dart';

class SignInWithGoogle implements UseCase<User, NoParams> {
  final AuthRepository repository;
  
  SignInWithGoogle(this.repository);
  
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}
