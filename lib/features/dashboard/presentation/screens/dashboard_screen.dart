import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:phishguard_ai/core/theme/app_colors.dart';
import 'package:phishguard_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:phishguard_ai/features/learning/presentation/providers/learning_provider.dart';
import 'package:phishguard_ai/features/scan/presentation/providers/scan_provider.dart';
import 'package:phishguard_ai/routing/app_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(learningProvider.notifier).loadLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final learningState = ref.watch(learningProvider);
    final scanState = ref.watch(scanProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              authState.user?.displayName ?? 'User',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(learningProvider.notifier).loadLessons();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Risk Score Card
            _RiskScoreCard(
              riskScore: learningState.progress?.phishingRiskScore ?? 0.5,
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.radar,
                    label: 'Quick Scan',
                    color: AppColors.primary,
                    onTap: () => context.go(AppRoutes.scan),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.school,
                    label: 'Learn',
                    color: AppColors.secondary,
                    onTap: () => context.go(AppRoutes.learning),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.shield,
                    label: 'Response',
                    color: AppColors.warning,
                    onTap: () => context.go(AppRoutes.incident),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Section
            if (learningState.progress != null) ...[
              Text(
                'Your Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _ProgressCard(progress: learningState.progress!),
              const SizedBox(height: 24),
            ],

            // Recent Scans
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (scanState.history.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.radar_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No scans yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.scan),
                        child: const Text('Start your first scan'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...scanState.history.take(5).map(
                    (scan) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scan.isSafe
                              ? AppColors.riskSafe.withValues(alpha: 0.1)
                              : scan.isSuspicious
                                  ? AppColors.riskMedium.withValues(alpha: 0.1)
                                  : AppColors.riskCritical.withValues(alpha: 0.1),
                          child: Icon(
                            scan.isSafe
                                ? Icons.check_circle
                                : scan.isSuspicious
                                    ? Icons.warning
                                    : Icons.dangerous,
                            color: scan.isSafe
                                ? AppColors.riskSafe
                                : scan.isSuspicious
                                    ? AppColors.riskMedium
                                    : AppColors.riskCritical,
                          ),
                        ),
                        title: Text(scan.classificationLabel),
                        subtitle: Text(
                          '${scan.inputType.name.toUpperCase()} - '
                          '${(scan.confidenceScore * 100).toStringAsFixed(0)}% confidence',
                        ),
                        trailing: Text(
                          _formatTime(scan.analyzedAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _RiskScoreCard extends StatelessWidget {
  final double riskScore;

  const _RiskScoreCard({required this.riskScore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = riskScore < 0.3
        ? AppColors.riskSafe
        : riskScore < 0.6
            ? AppColors.riskMedium
            : AppColors.riskHigh;
    final label = riskScore < 0.3
        ? 'Low Risk'
        : riskScore < 0.6
            ? 'Medium Risk'
            : 'High Risk';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 45,
              lineWidth: 8,
              percent: 1 - riskScore,
              center: Text(
                ((1 - riskScore) * 100).toStringAsFixed(0),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: color,
              backgroundColor: color.withValues(alpha: 0.15),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Score',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete more lessons to improve your score',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final dynamic progress;

  const _ProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.star,
                  value: '${progress.totalXp}',
                  label: 'Total XP',
                  color: AppColors.xpGold,
                ),
                _StatItem(
                  icon: Icons.trending_up,
                  value: 'Lv.${progress.currentLevel}',
                  label: 'Level',
                  color: AppColors.primary,
                ),
                _StatItem(
                  icon: Icons.local_fire_department,
                  value: '${progress.streakDays}',
                  label: 'Day Streak',
                  color: AppColors.warning,
                ),
                _StatItem(
                  icon: Icons.workspace_premium,
                  value: '${progress.badges.length}',
                  label: 'Badges',
                  color: AppColors.badgeGold,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.levelProgress,
                minHeight: 6,
                backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${progress.xpToNextLevel} XP to next level',
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}
