import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/exceptions.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/security/security_service.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:phishguard_ai/features/auth/domain/entities/user.dart';
import 'package:phishguard_ai/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecurityService _securityService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecurityService securityService,
  })  : _remoteDataSource = remoteDataSource,
        _securityService = securityService;

  @override
  ResultFuture<User> login({required String email, required String password}) async {
    try {
      final user = await _remoteDataSource.login(email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  ResultFuture<User> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  ResultFuture<void> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  ResultFuture<User> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  ResultFuture<bool> refreshToken() async {
    try {
      final result = await _remoteDataSource.refreshToken();
      return Right(result);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<bool> authenticateWithBiometrics() async {
    try {
      final result = await _securityService.authenticateWithBiometrics();
      return Right(result);
    } catch (e) {
      return Left(SecurityFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> hasValidSession() async {
    return _securityService.hasValidSession();
  }
}
