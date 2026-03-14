import 'package:equatable/equatable.dart';

class LearningBadge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final DateTime earnedAt;

  const LearningBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.earnedAt,
  });

  @override
  List<Object?> get props => [id, name];
}

class UserProgress extends Equatable {
  final String userId;
  final int totalXp;
  final int currentLevel;
  final double phishingRiskScore;
  final List<String> completedLessonIds;
  final List<LearningBadge> badges;
  final Map<String, int> quizScores;
  final int streakDays;
  final DateTime lastActivityDate;

  const UserProgress({
    required this.userId,
    required this.totalXp,
    required this.currentLevel,
    required this.phishingRiskScore,
    required this.completedLessonIds,
    required this.badges,
    required this.quizScores,
    required this.streakDays,
    required this.lastActivityDate,
  });

  double get levelProgress => (totalXp % 500) / 500.0;
  int get xpToNextLevel => 500 - (totalXp % 500);
  bool hasCompletedLesson(String lessonId) => completedLessonIds.contains(lessonId);

  @override
  List<Object?> get props => [userId, totalXp, currentLevel, completedLessonIds, badges];
}
