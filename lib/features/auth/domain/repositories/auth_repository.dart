import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  ResultFuture<User> login({required String email, required String password});
  ResultFuture<User> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  });
  ResultFuture<void> logout();
  ResultFuture<User> getCurrentUser();
  ResultFuture<bool> refreshToken();
  ResultFuture<bool> authenticateWithBiometrics();
  Future<bool> hasValidSession();
}
