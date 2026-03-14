import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:phishguard_ai/core/theme/app_colors.dart';
import 'package:phishguard_ai/features/learning/domain/entities/lesson.dart';
import 'package:phishguard_ai/features/learning/domain/entities/user_progress.dart';
import 'package:phishguard_ai/features/learning/presentation/providers/learning_provider.dart';

class LearningHubScreen extends ConsumerStatefulWidget {
  const LearningHubScreen({super.key});

  @override
  ConsumerState<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends ConsumerState<LearningHubScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(learningProvider.notifier).loadLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(learningProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub'),
        actions: [
          if (state.progress != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar: const Icon(Icons.star, size: 16, color: AppColors.xpGold),
                label: Text('${state.progress!.totalXp} XP'),
              ),
            ),
        ],
      ),
      body: state.status == LearningStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : state.status == LearningStatus.error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(state.errorMessage ?? 'Failed to load lessons'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(learningProvider.notifier).loadLessons(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(learningProvider.notifier).loadLessons();
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // XP Progress
                      if (state.progress != null) ...[
                        _XpProgressCard(progress: state.progress!),
                        const SizedBox(height: 24),
                      ],

                      // Badges
                      if (state.progress != null &&
                          state.progress!.badges.isNotEmpty) ...[
                        Text(
                          'Your Badges',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.progress!.badges.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final badge = state.progress!.badges[index];
                              return _BadgeChip(badge: badge);
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Recommended Lessons
                      Text(
                        'Recommended For You',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.recommendedLessons.map(
                        (lesson) => _LessonCard(
                          lesson: lesson,
                          isCompleted: state.progress?.hasCompletedLesson(lesson.id) ?? false,
                          onTap: () => context.go('/learning/${lesson.id}'),
                        ),
                      ),

                      if (state.recommendedLessons.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No lessons available yet',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _XpProgressCard extends StatelessWidget {
  final UserProgress progress;

  const _XpProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level ${progress.currentLevel}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        '${progress.streakDays} day streak',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearPercentIndicator(
              lineHeight: 12,
              percent: progress.levelProgress,
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              progressColor: AppColors.primary,
              barRadius: const Radius.circular(6),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.xpToNextLevel} XP to Level ${progress.currentLevel + 1}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final LearningBadge badge;

  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.badgeGold.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.workspace_premium, color: AppColors.badgeGold),
        ),
        const SizedBox(height: 4),
        Text(
          badge.name,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isCompleted,
    required this.onTap,
  });

  Color get _difficultyColor {
    switch (lesson.difficulty) {
      case LessonDifficulty.beginner:
        return AppColors.riskSafe;
      case LessonDifficulty.intermediate:
        return AppColors.riskMedium;
      case LessonDifficulty.advanced:
        return AppColors.riskHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _difficultyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                  color: isCompleted ? AppColors.riskSafe : _difficultyColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.durationMinutes} min',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _difficultyColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            lesson.difficulty.name,
                            style: TextStyle(
                              color: _difficultyColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.star, size: 14, color: AppColors.xpGold),
                        const SizedBox(width: 2),
                        Text(
                          '+${lesson.xpReward} XP',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
