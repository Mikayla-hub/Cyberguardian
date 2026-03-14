import 'package:logger/logger.dart';
import 'package:phishguard_ai/core/config/env_config.dart';

class SecureLogger {
  static late final Logger _logger;
  static late final EnvConfig _config;

  static void init(EnvConfig config) {
    _config = config;
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: config.enableLogging ? Level.debug : Level.warning,
    );
  }

  static void debug(String message) {
    if (_config.enableLogging) {
      _logger.d(_sanitize(message));
    }
  }

  static void info(String message) {
    _logger.i(_sanitize(message));
  }

  static void warning(String message) {
    _logger.w(_sanitize(message));
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(_sanitize(message), error: error, stackTrace: stackTrace);
  }

  static String _sanitize(String message) {
    return message
        .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*'), 'Bearer [REDACTED]')
        .replaceAll(RegExp(r'"password"\s*:\s*"[^"]*"'), '"password": "[REDACTED]"')
        .replaceAll(RegExp(r'"token"\s*:\s*"[^"]*"'), '"token": "[REDACTED]"')
        .replaceAll(RegExp(r'"refresh_token"\s*:\s*"[^"]*"'), '"refresh_token": "[REDACTED]"');
  }
}
