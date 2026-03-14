import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/auth/domain/entities/user.dart';
import 'package:phishguard_ai/features/auth/domain/repositories/auth_repository.dart';

class Login {
  final AuthRepository _repository;

  const Login(this._repository);

  ResultFuture<User> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
