import 'package:phishguard_ai/features/learning/domain/entities/lesson.dart';

class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.correctIndex,
    required super.explanation,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctIndex: json['correct_index'] as int,
      explanation: json['explanation'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correct_index': correctIndex,
        'explanation': explanation,
      };
}

class LessonContentModel extends LessonContent {
  const LessonContentModel({
    required super.type,
    required super.data,
    super.metadata,
  });

  factory LessonContentModel.fromJson(Map<String, dynamic> json) {
    return LessonContentModel(
      type: json['type'] as String,
      data: json['data'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        if (metadata != null) 'metadata': metadata,
      };
}

class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.difficulty,
    required super.durationMinutes,
    required super.contents,
    required super.quiz,
    required super.xpReward,
    super.badgeId,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: LessonCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => LessonCategory.emailPhishing,
      ),
      difficulty: LessonDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => LessonDifficulty.beginner,
      ),
      durationMinutes: json['duration_minutes'] as int,
      contents: (json['contents'] as List<dynamic>?)
              ?.map((e) => LessonContentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      quiz: (json['quiz'] as List<dynamic>?)
              ?.map((e) => QuizQuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      xpReward: json['xp_reward'] as int? ?? 50,
      badgeId: json['badge_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'difficulty': difficulty.name,
        'duration_minutes': durationMinutes,
        'contents': contents
            .map((e) => {'type': e.type, 'data': e.data, 'metadata': e.metadata})
            .toList(),
        'quiz': quiz
            .map((e) => {
                  'id': e.id,
                  'question': e.question,
                  'options': e.options,
                  'correct_index': e.correctIndex,
                  'explanation': e.explanation,
                })
            .toList(),
        'xp_reward': xpReward,
        'badge_id': badgeId,
      };
}
