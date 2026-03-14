import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phishguard_ai/core/theme/app_colors.dart';
import 'package:phishguard_ai/features/learning/presentation/providers/learning_provider.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  int _currentPage = 0;
  bool _inQuiz = false;
  int? _selectedAnswer;
  bool _showExplanation = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(learningProvider);
    final lesson = state.currentLesson;
    final theme = Theme.of(context);

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    final isQuizComplete = state.currentQuizIndex >= lesson.quiz.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _inQuiz
                ? (lesson.quiz.isEmpty ? 1.0 : state.currentQuizIndex / lesson.quiz.length)
                : (lesson.contents.isEmpty ? 1.0 : (_currentPage + 1) / lesson.contents.length),
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      body: _inQuiz
          ? isQuizComplete
              ? _QuizCompleteView(
                  correctAnswers: state.correctAnswers,
                  totalQuestions: lesson.quiz.length,
                  xpEarned: lesson.xpReward,
                  onFinish: () async {
                    await ref.read(learningProvider.notifier).completeCurrentLesson();
                    if (context.mounted) context.pop();
                  },
                )
              : _QuizView(
                  question: lesson.quiz[state.currentQuizIndex],
                  questionIndex: state.currentQuizIndex,
                  totalQuestions: lesson.quiz.length,
                  selectedAnswer: _selectedAnswer,
                  showExplanation: _showExplanation,
                  onSelectAnswer: (index) {
                    setState(() {
                      _selectedAnswer = index;
                      _showExplanation = true;
                    });
                  },
                  onNext: () {
                    ref.read(learningProvider.notifier).answerQuiz(_selectedAnswer!);
                    setState(() {
                      _selectedAnswer = null;
                      _showExplanation = false;
                    });
                  },
                )
          : _ContentView(
              content: lesson.contents.isEmpty ? null : lesson.contents[_currentPage],
              currentPage: _currentPage,
              totalPages: lesson.contents.length,
              onNext: () {
                if (_currentPage < lesson.contents.length - 1) {
                  setState(() => _currentPage++);
                } else {
                  setState(() => _inQuiz = true);
                }
              },
              onPrevious: _currentPage > 0
                  ? () => setState(() => _currentPage--)
                  : null,
            ),
    );
  }
}

class _ContentView extends StatelessWidget {
  final dynamic content;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;

  const _ContentView({
    required this.content,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: content != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content.type == 'text')
                        Text(content.data, style: theme.textTheme.bodyLarge),
                      if (content.type == 'interactive')
                        Card(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(Icons.touch_app, size: 32, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(content.data, style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                : Center(
                    child: Text('No content available', style: theme.textTheme.bodyLarge),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (onPrevious != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPrevious,
                    child: const Text('Previous'),
                  ),
                ),
              if (onPrevious != null) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    currentPage < totalPages - 1 ? 'Next' : 'Start Quiz',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizView extends StatelessWidget {
  final dynamic question;
  final int questionIndex;
  final int totalQuestions;
  final int? selectedAnswer;
  final bool showExplanation;
  final void Function(int) onSelectAnswer;
  final VoidCallback onNext;

  const _QuizView({
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.showExplanation,
    required this.onSelectAnswer,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${questionIndex + 1} of $totalQuestions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  question.question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(question.options.length, (index) {
                  final isSelected = selectedAnswer == index;
                  final isCorrect = index == question.correctIndex;
                  final showResult = showExplanation;

                  Color borderColor = theme.colorScheme.outline;
                  Color? bgColor;
                  if (showResult && isCorrect) {
                    borderColor = AppColors.riskSafe;
                    bgColor = AppColors.riskSafe.withValues(alpha: 0.05);
                  } else if (showResult && isSelected && !isCorrect) {
                    borderColor = AppColors.riskCritical;
                    bgColor = AppColors.riskCritical.withValues(alpha: 0.05);
                  } else if (isSelected) {
                    borderColor = AppColors.primary;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: showExplanation ? null : () => onSelectAnswer(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                          color: bgColor,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: borderColor),
                                color: isSelected ? borderColor : null,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : borderColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            if (showResult && isCorrect)
                              const Icon(Icons.check_circle, color: AppColors.riskSafe, size: 20),
                            if (showResult && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: AppColors.riskCritical, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (showExplanation) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            question.explanation,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showExplanation)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next'),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuizCompleteView extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int xpEarned;
  final VoidCallback onFinish;

  const _QuizCompleteView({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.xpEarned,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final score = totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).round() : 100;
    final passed = score >= 60;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passed ? Icons.celebration : Icons.refresh,
              size: 64,
              color: passed ? AppColors.xpGold : AppColors.riskMedium,
            ),
            const SizedBox(height: 24),
            Text(
              passed ? 'Lesson Complete!' : 'Keep Practicing!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$correctAnswers / $totalQuestions correct ($score%)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            if (passed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.xpGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppColors.xpGold),
                    const SizedBox(width: 8),
                    Text(
                      '+$xpEarned XP',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.xpGold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
