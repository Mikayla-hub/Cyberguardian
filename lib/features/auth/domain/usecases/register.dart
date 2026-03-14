import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/auth/domain/entities/user.dart';
import 'package:phishguard_ai/features/auth/domain/repositories/auth_repository.dart';

class Register {
  final AuthRepository _repository;

  const Register(this._repository);

  ResultFuture<User> call({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) {
    return _repository.register(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
  }
}
