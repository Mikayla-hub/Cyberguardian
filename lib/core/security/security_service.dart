import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:phishguard_ai/core/errors/exceptions.dart';
import 'package:phishguard_ai/core/utils/secure_logger.dart';

class SecurityService {
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  SecurityService({
    required FlutterSecureStorage secureStorage,
    required LocalAuthentication localAuth,
  })  : _secureStorage = secureStorage,
        _localAuth = localAuth;

  /// Check device integrity - root/jailbreak
  Future<bool> isDeviceCompromised() async {
    try {
      return await FlutterJailbreakDetection.jailbroken;
    } catch (e) {
      SecureLogger.warning('Could not check device integrity: $e');
      return false;
    }
  }

  /// Biometric authentication
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canAuthenticate || !isDeviceSupported) {
        return true; // Skip biometric if not available
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access PhishGuard AI',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      SecureLogger.error('Biometric auth error: ${e.message}');
      return false;
    }
  }

  /// Check available biometrics
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Enable screenshot blocking (Android only)
  Future<void> enableScreenshotBlocking() async {
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('com.phishguard.ai/security');
        await channel.invokeMethod('enableScreenshotBlocking');
      } catch (e) {
        SecureLogger.warning('Screenshot blocking not available: $e');
      }
    }
  }

  /// Secure token storage
  Future<void> storeToken(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readToken(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> clearTokens() async {
    await _secureStorage.deleteAll();
  }

  /// Validate session
  Future<bool> hasValidSession() async {
    final token = await readToken('access_token');
    if (token == null) return false;
    // In production, decode JWT and check expiration
    return true;
  }

  /// Perform full security check
  Future<void> performSecurityCheck() async {
    final compromised = await isDeviceCompromised();
    if (compromised) {
      throw const SecurityException(
        message: 'This device appears to be rooted/jailbroken. '
            'For security, PhishGuard AI cannot run on compromised devices.',
      );
    }
  }
}
