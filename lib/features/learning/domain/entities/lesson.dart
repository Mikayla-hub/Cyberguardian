import 'package:equatable/equatable.dart';

enum LessonDifficulty { beginner, intermediate, advanced }

enum LessonCategory { emailPhishing, websiteSpoofing, smishing, socialEngineering, safeBehavior }

class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  @override
  List<Object?> get props => [id, question, options, correctIndex, explanation];
}

class Lesson extends Equatable {
  final String id;
  final String title;
  final String description;
  final LessonCategory category;
  final LessonDifficulty difficulty;
  final int durationMinutes;
  final List<LessonContent> contents;
  final List<QuizQuestion> quiz;
  final int xpReward;
  final String? badgeId;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationMinutes,
    required this.contents,
    required this.quiz,
    required this.xpReward,
    this.badgeId,
  });

  @override
  List<Object?> get props => [id, title, category, difficulty];
}

class LessonContent extends Equatable {
  final String type; // text, image, interactive, simulation
  final String data;
  final Map<String, dynamic>? metadata;

  const LessonContent({
    required this.type,
    required this.data,
    this.metadata,
  });

  @override
  List<Object?> get props => [type, data];
}
