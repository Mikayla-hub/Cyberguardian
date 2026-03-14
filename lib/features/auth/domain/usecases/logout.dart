import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/auth/domain/repositories/auth_repository.dart';

class Logout {
  final AuthRepository _repository;

  const Logout(this._repository);

  ResultVoid call() {
    return _repository.logout();
  }
}
