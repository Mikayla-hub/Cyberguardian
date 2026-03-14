import 'dart:math';

import 'package:phishguard_ai/core/constants/api_constants.dart';
import 'package:phishguard_ai/core/utils/secure_logger.dart';

class RetryPolicy {
  final int maxRetries;
  final Duration baseDelay;

  const RetryPolicy({
    this.maxRetries = ApiConstants.maxRetries,
    this.baseDelay = ApiConstants.retryDelay,
  });

  Future<T> execute<T>(Future<T> Function() action, {String? operationName}) async {
    int attempt = 0;
    while (true) {
      try {
        attempt++;
        return await action();
      } catch (e) {
        if (attempt >= maxRetries) {
          SecureLogger.error(
            '${operationName ?? "Operation"} failed after $maxRetries attempts',
          );
          rethrow;
        }
        final delay = baseDelay * pow(2, attempt - 1).toInt();
        SecureLogger.warning(
          '${operationName ?? "Operation"} attempt $attempt failed, retrying in ${delay.inSeconds}s',
        );
        await Future.delayed(delay);
      }
    }
  }
}
