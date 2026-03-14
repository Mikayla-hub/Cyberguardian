abstract final class AppConstants {
  static const String appName = 'PhishGuard AI';
  static const String appVersion = '1.0.0';

  // Learning module
  static const int maxLessonDurationMinutes = 15;
  static const int xpPerQuizCorrect = 10;
  static const int xpPerLessonComplete = 50;
  static const int xpPerModuleComplete = 200;

  // Risk scores
  static const double lowRiskThreshold = 0.3;
  static const double mediumRiskThreshold = 0.6;
  static const double highRiskThreshold = 0.8;

  // Cache
  static const Duration cacheValidDuration = Duration(hours: 24);
  static const String lessonsCacheKey = 'cached_lessons';
  static const String progressCacheKey = 'cached_progress';
  static const String userCacheKey = 'cached_user';

  // Security
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);
}
