import 'package:phishguard_ai/features/learning/domain/entities/user_progress.dart';

class BadgeModel extends LearningBadge {
  const BadgeModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconUrl,
    required super.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon_url': iconUrl,
        'earned_at': earnedAt.toIso8601String(),
      };
}

class UserProgressModel extends UserProgress {
  const UserProgressModel({
    required super.userId,
    required super.totalXp,
    required super.currentLevel,
    required super.phishingRiskScore,
    required super.completedLessonIds,
    required super.badges,
    required super.quizScores,
    required super.streakDays,
    required super.lastActivityDate,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      userId: json['user_id'] as String,
      totalXp: json['total_xp'] as int,
      currentLevel: json['current_level'] as int,
      phishingRiskScore: (json['phishing_risk_score'] as num).toDouble(),
      completedLessonIds:
          (json['completed_lesson_ids'] as List<dynamic>).cast<String>(),
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      quizScores: (json['quiz_scores'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      streakDays: json['streak_days'] as int? ?? 0,
      lastActivityDate: DateTime.parse(json['last_activity_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'total_xp': totalXp,
        'current_level': currentLevel,
        'phishing_risk_score': phishingRiskScore,
        'completed_lesson_ids': completedLessonIds,
        'badges': badges
            .map((b) => {
                  'id': b.id,
                  'name': b.name,
                  'description': b.description,
                  'icon_url': b.iconUrl,
                  'earned_at': b.earnedAt.toIso8601String(),
                })
            .toList(),
        'quiz_scores': quizScores,
        'streak_days': streakDays,
        'last_activity_date': lastActivityDate.toIso8601String(),
      };
}
