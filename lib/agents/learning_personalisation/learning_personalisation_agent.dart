import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/constants/app_constants.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/network/retry_policy.dart';
import 'package:phishguard_ai/core/security/audit_logger.dart';
import 'package:phishguard_ai/core/utils/secure_logger.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/learning/domain/entities/lesson.dart';
import 'package:phishguard_ai/features/learning/domain/entities/user_progress.dart';
import 'package:phishguard_ai/features/learning/domain/repositories/learning_repository.dart';

/// Agent responsible for personalising the learning experience.
///
/// Tracks user progress, adjusts lesson difficulty based on performance,
/// recommends training modules, calculates phishing risk scores,
/// and manages the gamification system (XP and badges).
class LearningPersonalisationAgent {
  final LearningRepository _learningRepository;
  final RetryPolicy _retryPolicy;
  final AuditLogger _auditLogger;

  static const String agentName = 'LearningPersonalisationAgent';

  LearningPersonalisationAgent({
    required LearningRepository learningRepository,
    required RetryPolicy retryPolicy,
    required AuditLogger auditLogger,
  })  : _learningRepository = learningRepository,
        _retryPolicy = retryPolicy,
        _auditLogger = auditLogger;

  /// Get the current user's learning progress.
  ResultFuture<UserProgress> getUserProgress() async {
    try {
      return await _retryPolicy.execute(
        () => _learningRepository.getUserProgress(),
        operationName: '$agentName.getUserProgress',
      );
    } catch (e) {
      SecureLogger.error('$agentName failed to get user progress', e);
      return Left(AgentFailure(message: e.toString(), agentName: agentName));
    }
  }

  /// Complete a lesson and award XP.
  ResultFuture<UserProgress> completeLesson(String lessonId, int quizScore) async {
    try {
      final result = await _retryPolicy.execute(
        () => _learningRepository.completeLesson(lessonId, quizScore),
        operationName: '$agentName.completeLesson',
      );

      result.fold(
        (_) {},
        (progress) {
          _auditLogger.log(AuditEntry(
            action: AuditAction.lessonCompleted,
            description: 'Lesson $lessonId completed with score $quizScore',
            metadata: {
              'lessonId': lessonId,
              'quizScore': quizScore,
              'totalXp': progress.totalXp,
              'level': progress.currentLevel,
            },
          ));
        },
      );

      return result;
    } catch (e) {
      SecureLogger.error('$agentName failed to complete lesson', e);
      return Left(AgentFailure(message: e.toString(), agentName: agentName));
    }
  }

  /// Recommend next lessons based on user performance and gaps.
  ResultFuture<List<Lesson>> getRecommendedLessons(String userId) async {
    try {
      return await _retryPolicy.execute(
        () => _learningRepository.getRecommendedLessons(userId),
        operationName: '$agentName.getRecommendedLessons',
      );
    } catch (e) {
      SecureLogger.error('$agentName failed to get recommendations', e);
      return Left(AgentFailure(message: e.toString(), agentName: agentName));
    }
  }

  /// Calculate the appropriate difficulty for the next lesson.
  LessonDifficulty calculateNextDifficulty(UserProgress progress) {
    final avgScore = progress.quizScores.isEmpty
        ? 0.0
        : progress.quizScores.values.reduce((a, b) => a + b) /
            progress.quizScores.length;

    if (avgScore >= 85 && progress.completedLessonIds.length >= 5) {
      return LessonDifficulty.advanced;
    } else if (avgScore >= 60 && progress.completedLessonIds.length >= 2) {
      return LessonDifficulty.intermediate;
    }
    return LessonDifficulty.beginner;
  }

  /// Calculate the user's phishing risk score (0.0 = no risk, 1.0 = high risk).
  double calculateRiskScore(UserProgress progress) {
    double score = 1.0;

    // Lower risk based on lessons completed
    score -= (progress.completedLessonIds.length * 0.05).clamp(0.0, 0.3);

    // Lower risk based on quiz performance
    if (progress.quizScores.isNotEmpty) {
      final avgScore = progress.quizScores.values.reduce((a, b) => a + b) /
          progress.quizScores.length;
      score -= (avgScore / 100 * 0.3).clamp(0.0, 0.3);
    }

    // Lower risk based on streak
    score -= (progress.streakDays * 0.02).clamp(0.0, 0.2);

    // Lower risk based on level
    score -= (progress.currentLevel * 0.02).clamp(0.0, 0.2);

    return score.clamp(0.0, 1.0);
  }

  /// Calculate XP to award for a quiz.
  int calculateXpReward(int quizScore, LessonDifficulty difficulty) {
    int baseXp = AppConstants.xpPerLessonComplete;

    // Bonus for quiz performance
    final quizXp = (quizScore / 100 * AppConstants.xpPerQuizCorrect * 5).round();

    // Difficulty multiplier
    final multiplier = switch (difficulty) {
      LessonDifficulty.beginner => 1.0,
      LessonDifficulty.intermediate => 1.5,
      LessonDifficulty.advanced => 2.0,
    };

    return ((baseXp + quizXp) * multiplier).round();
  }

  /// Cache lessons for offline access.
  ResultFuture<void> cacheLessonsOffline(List<Lesson> lessons) async {
    try {
      return await _learningRepository.cacheLessonsLocally(lessons);
    } catch (e) {
      SecureLogger.error('$agentName failed to cache lessons', e);
      return Left(AgentFailure(message: e.toString(), agentName: agentName));
    }
  }
}
