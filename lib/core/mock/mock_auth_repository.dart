import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/auth/domain/entities/user.dart';
import 'package:phishguard_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';

class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  @override
  ResultFuture<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (password.length < 8) {
      return const Left(AuthFailure(message: 'Invalid email or password'));
    }

    _currentUser = User(
      id: 'usr_demo_001',
      email: email,
      displayName: email.split('@').first.replaceAll('.', ' '),
      role: UserRole.employee,
      biometricEnabled: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
    );
    return Right(_currentUser!);
  }

  @override
  ResultFuture<User> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final userRole = UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.employee,
    );

    _currentUser = User(
      id: 'usr_demo_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      role: userRole,
      biometricEnabled: false,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    return Right(_currentUser!);
  }

  @override
  ResultFuture<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    return const Right(null);
  }

  @override
  ResultFuture<User> getCurrentUser() async {
    if (_currentUser != null) return Right(_currentUser!);
    return const Left(AuthFailure(message: 'Not authenticated'));
  }

  @override
  ResultFuture<bool> refreshToken() async {
    return const Right(true);
  }

  @override
  ResultFuture<bool> authenticateWithBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(true);
  }

  @override
  Future<bool> hasValidSession() async {
    return _currentUser != null;
  }
}
