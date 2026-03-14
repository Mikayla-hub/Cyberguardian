abstract final class ApiConstants {
  static const String baseUrl = 'https://api.phishguard.ai/v1';
  static const String analyzeEndpoint = '/analyze';
  static const String reportEndpoint = '/report';
  static const String lessonsEndpoint = '/lessons';
  static const String incidentResponseEndpoint = '/incident-response';
  static const String authEndpoint = '/auth';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String userProfileEndpoint = '/user/profile';
  static const String progressEndpoint = '/user/progress';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
