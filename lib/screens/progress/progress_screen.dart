import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/topic.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/async_content.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/weekly_chart.dart';

/// Stats, weekly activity chart and per-topic progress.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final code = context.watch<SettingsProvider>().languageCode;

    if (progress.isLoading) {
      return const Scaffold(body: LoadingView(message: 'Loading progress…'));
    }

    final week = progress.weeklyActivity;
    final weekXp = week.fold<int>(0, (s, d) => s + d.$2);

    return Scaffold(
      appBar: AppBar(title: const Text('Your progress')),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            0,
            AppConstants.pagePadding,
            AppConstants.pagePadding,
          ),
          children: [
            _XpBanner(totalXp: progress.xp),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.75,
              children: [
                StatTile(
                  value: '${code == null ? 0 : progress.learnedCount(code)}',
                  label: 'Words learned',
                  icon: Icons.translate_rounded,
                  color: AppColors.primary,
                ),
                StatTile(
                  value: '${progress.quizzesTaken}',
                  label: 'Quizzes taken',
                  icon: Icons.quiz_rounded,
                  color: AppColors.sky,
                ),
                StatTile(
                  value: '${progress.averageScore.round()}%',
                  label: 'Average score',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.secondary,
                ),
                StatTile(
                  value: '${progress.streak} 🔥',
                  label: 'Day streak',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.streak,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'This week · $weekXp XP'),
            AppCard(
              padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
              child: SizedBox(
                height: 200,
                child: weekXp == 0
                    ? const EmptyView(
                        compact: true,
                        icon: Icons.bar_chart_rounded,
                        title: 'No activity this week yet',
                        message: 'Complete a lesson to see your chart grow.',
                      )
                    : WeeklyActivityChart(days: week),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Topics'),
            if (code == null)
              const EmptyView(title: 'No language selected', compact: true)
            else
              AsyncContent<List<Topic>>(
                key: ValueKey(code),
                compact: true,
                load: () => context.read<ContentRepository>().getTopics(code),
                isEmpty: (t) => t.isEmpty,
                emptyTitle: 'No topics yet',
                builder: (context, topics, _) => AppCard(
                  child: Column(
                    children: [
                      for (final t in topics)
                        _TopicProgressRow(
                          topic: t,
                          value: progress.topicProgress(t),
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

class _XpBanner extends StatelessWidget {
  const _XpBanner({required this.totalXp});
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: totalXp),
                  duration: const Duration(milliseconds: 900),
                  builder: (_, v, _) => Text(
                    '$v XP',
                    style: context.text.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Total experience',
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicProgressRow extends StatelessWidget {
  const _TopicProgressRow({required this.topic, required this.value});
  final Topic topic;
  final double value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.pushNamed(
        AppRoutes.wordList,
        pathParameters: {'topicId': topic.id},
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(topic.icon, color: topic.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          topic.title,
                          style: context.text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${(value * 100).round()}%',
                        style: context.text.labelLarge?.copyWith(
                          color: topic.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AppProgressBar(value: value, color: topic.color, height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
