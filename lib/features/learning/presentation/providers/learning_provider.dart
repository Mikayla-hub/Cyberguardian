import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_ai/agents/learning_personalisation/learning_personalisation_agent.dart';
import 'package:phishguard_ai/core/di/agent_providers.dart';
import 'package:phishguard_ai/features/learning/domain/entities/lesson.dart';
import 'package:phishguard_ai/features/learning/domain/entities/user_progress.dart';

enum LearningStatus { initial, loading, loaded, error }

class LearningState {
  final LearningStatus status;
  final List<Lesson> lessons;
  final List<Lesson> recommendedLessons;
  final UserProgress? progress;
  final Lesson? currentLesson;
  final int currentQuizIndex;
  final int correctAnswers;
  final String? errorMessage;

  const LearningState({
    this.status = LearningStatus.initial,
    this.lessons = const [],
    this.recommendedLessons = const [],
    this.progress,
    this.currentLesson,
    this.currentQuizIndex = 0,
    this.correctAnswers = 0,
    this.errorMessage,
  });

  LearningState copyWith({
    LearningStatus? status,
    List<Lesson>? lessons,
    List<Lesson>? recommendedLessons,
    UserProgress? progress,
    Lesson? currentLesson,
    int? currentQuizIndex,
    int? correctAnswers,
    String? errorMessage,
  }) {
    return LearningState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      recommendedLessons: recommendedLessons ?? this.recommendedLessons,
      progress: progress ?? this.progress,
      currentLesson: currentLesson ?? this.currentLesson,
      currentQuizIndex: currentQuizIndex ?? this.currentQuizIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LearningNotifier extends StateNotifier<LearningState> {
  final LearningPersonalisationAgent _agent;

  LearningNotifier(this._agent) : super(const LearningState());

  Future<void> loadLessons() async {
    state = state.copyWith(status: LearningStatus.loading);

    final progressResult = await _agent.getUserProgress();
    progressResult.fold(
      (failure) => state = state.copyWith(
        status: LearningStatus.error,
        errorMessage: failure.message,
      ),
      (progress) => state = state.copyWith(progress: progress),
    );

    final result = await _agent.getRecommendedLessons(state.progress?.userId ?? '');
    result.fold(
      (failure) => state = state.copyWith(
        status: LearningStatus.error,
        errorMessage: failure.message,
      ),
      (lessons) => state = state.copyWith(
        status: LearningStatus.loaded,
        recommendedLessons: lessons,
      ),
    );
  }

  void startLesson(Lesson lesson) {
    state = state.copyWith(
      currentLesson: lesson,
      currentQuizIndex: 0,
      correctAnswers: 0,
    );
  }

  void answerQuiz(int selectedIndex) {
    final quiz = state.currentLesson?.quiz[state.currentQuizIndex];
    if (quiz == null) return;

    final isCorrect = selectedIndex == quiz.correctIndex;
    state = state.copyWith(
      currentQuizIndex: state.currentQuizIndex + 1,
      correctAnswers: state.correctAnswers + (isCorrect ? 1 : 0),
    );
  }

  Future<void> completeCurrentLesson() async {
    final lesson = state.currentLesson;
    if (lesson == null) return;

    final totalQuestions = lesson.quiz.length;
    final score = totalQuestions > 0
        ? ((state.correctAnswers / totalQuestions) * 100).round()
        : 100;

    final result = await _agent.completeLesson(lesson.id, score);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (progress) => state = state.copyWith(progress: progress),
    );
  }
}

final learningProvider = StateNotifierProvider<LearningNotifier, LearningState>((ref) {
  return LearningNotifier(ref.watch(learningPersonalisationAgentProvider));
});
