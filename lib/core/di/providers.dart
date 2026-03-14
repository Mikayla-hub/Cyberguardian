import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:phishguard_ai/core/config/env_config.dart';
import 'package:phishguard_ai/core/network/api_client.dart';
import 'package:phishguard_ai/core/network/network_info.dart';
import 'package:phishguard_ai/core/network/retry_policy.dart';
import 'package:phishguard_ai/core/security/audit_logger.dart';
import 'package:phishguard_ai/core/security/security_service.dart';

// ─── External Dependencies ───────────────────────────────────────

final envConfigProvider = Provider<EnvConfig>((ref) => EnvConfig.development);

final dioProvider = Provider<Dio>((ref) => Dio());

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  ),
);

final localAuthProvider = Provider<LocalAuthentication>((ref) => LocalAuthentication());

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final hiveCacheBoxProvider = Provider<Box<String>>((ref) {
  throw UnimplementedError('Must be overridden at app startup');
});

// ─── Core Services ───────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    dio: ref.watch(dioProvider),
    secureStorage: ref.watch(secureStorageProvider),
    config: ref.watch(envConfigProvider),
  );
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(connectivity: ref.watch(connectivityProvider));
});

final retryPolicyProvider = Provider<RetryPolicy>((ref) => const RetryPolicy());

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService(
    secureStorage: ref.watch(secureStorageProvider),
    localAuth: ref.watch(localAuthProvider),
  );
});

final auditLoggerProvider = Provider<AuditLogger>((ref) => AuditLogger());
