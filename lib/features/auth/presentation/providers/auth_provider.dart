import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_ai/core/di/feature_providers.dart';
import 'package:phishguard_ai/core/di/providers.dart';
import 'package:phishguard_ai/core/security/audit_logger.dart';
import 'package:phishguard_ai/features/auth/domain/entities/user.dart';
import 'package:phishguard_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:phishguard_ai/features/auth/domain/usecases/login.dart';
import 'package:phishguard_ai/features/auth/domain/usecases/logout.dart';
import 'package:phishguard_ai/features/auth/domain/usecases/register.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool biometricAvailable;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
    this.biometricAvailable = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? biometricAvailable,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Login _login;
  final Register _register;
  final Logout _logout;
  final AuthRepository _authRepository;
  final AuditLogger _auditLogger;

  AuthNotifier({
    required Login login,
    required Register register,
    required Logout logout,
    required AuthRepository authRepository,
    required AuditLogger auditLogger,
  })  : _login = login,
        _register = register,
        _logout = logout,
        _authRepository = authRepository,
        _auditLogger = auditLogger,
        super(const AuthState());

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    final result = await _login(email: email, password: password);
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) {
        _auditLogger.log(AuditEntry(
          action: AuditAction.login,
          description: 'User logged in: ${user.email}',
        ));
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    final result = await _register(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) {
        _auditLogger.log(AuditEntry(
          action: AuditAction.login,
          description: 'New user registered: ${user.email}',
        ));
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      },
    );
  }

  Future<void> signOut() async {
    await _logout();
    _auditLogger.log(AuditEntry(
      action: AuditAction.logout,
      description: 'User logged out',
    ));
    state = const AuthState();
  }

  Future<void> checkSession() async {
    final hasSession = await _authRepository.hasValidSession();
    if (hasSession) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (_) => state = const AuthState(),
        (user) => state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    }
  }

  Future<void> authenticateWithBiometrics() async {
    final result = await _authRepository.authenticateWithBiometrics();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        if (success) {
          _auditLogger.log(AuditEntry(
            action: AuditAction.biometricAuth,
            description: 'Biometric authentication successful',
          ));
          checkSession();
        }
      },
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    login: ref.watch(loginUseCaseProvider),
    register: ref.watch(registerUseCaseProvider),
    logout: ref.watch(logoutUseCaseProvider),
    authRepository: ref.watch(authRepositoryProvider),
    auditLogger: ref.watch(auditLoggerProvider),
  );
});
