import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/quiz_question.dart';
import '../../models/topic.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_tile.dart';

/// The Quiz tab: quick quiz, quiz by topic and stats.
class QuizHubScreen extends StatelessWidget {
  const QuizHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final code = context.watch<SettingsProvider>().languageCode;
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: code == null
          ? const EmptyView(title: 'No language selected')
          : ResponsiveCenter(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pagePadding,
                  0,
                  AppConstants.pagePadding,
                  AppConstants.pagePadding,
                ),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          value: '${progress.quizzesTaken}',
                          label: 'Quizzes taken',
                          icon: Icons.quiz_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          value: '${progress.averageScore.round()}%',
                          label: 'Average score',
                          icon: Icons.trending_up_rounded,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _QuickQuizCard(
                    onStart: () => context.pushNamed(AppRoutes.quizSession),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in QuizType.values)
                        Chip(
                          avatar: Icon(_typeIcon(t), size: 18),
                          label: Text(t.label),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Quiz by topic'),
                  AsyncContent<List<Topic>>(
                    key: ValueKey(code),
                    compact: true,
                    load: () =>
                        context.read<ContentRepository>().getTopics(code),
                    isEmpty: (t) => t.isEmpty,
                    emptyTitle: 'No topics yet',
                    builder: (context, topics, _) => Column(
                      children: [
                        for (final topic in topics)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TopicQuizTile(topic: topic),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  static IconData _typeIcon(QuizType t) => switch (t) {
    QuizType.multipleChoice => Icons.checklist_rounded,
    QuizType.listenAndChoose => Icons.headphones_rounded,
    QuizType.fillInBlank => Icons.edit_note_rounded,
    QuizType.matchPairs => Icons.compare_arrows_rounded,
  };
}

class _QuickQuizCard extends StatelessWidget {
  const _QuickQuizCard({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    return AppCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Quick Quiz',
                  style: context.text.titleLarge?.copyWith(
                    color: white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.bolt_rounded, color: white, size: 32),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${AppConstants.quizLength} questions from all topics · '
            '${AppConstants.maxHearts} hearts',
            style: context.text.bodyMedium?.copyWith(
              color: white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Start quiz',
            icon: Icons.play_arrow_rounded,
            variant: ButtonVariant.light,
            expand: false,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _TopicQuizTile extends StatelessWidget {
  const _TopicQuizTile({required this.topic});
  final Topic topic;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => context.pushNamed(
        AppRoutes.quizSession,
        queryParameters: {'topicId': topic.id},
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: topic.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(topic.icon, color: topic.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${topic.somaliTitle} · 10 questions',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.play_circle_fill_rounded,
            color: context.colors.primary,
            size: 32,
          ),
        ],
      ),
    );
  }
}
