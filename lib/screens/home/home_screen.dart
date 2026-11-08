import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../core/utils/date_utils.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/language.dart';
import '../../models/topic.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/section_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/topic_card.dart';
import '../../widgets/user_avatar.dart';

/// Dashboard: greeting, streak, daily goal, today's lesson, sections and
/// recent topics.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final code = context.watch<SettingsProvider>().languageCode;

    return Scaffold(
      body: SafeArea(
        child: code == null
            ? EmptyView(
                title: 'Pick a language to start',
                icon: Icons.language_rounded,
                action: PrimaryButton(
                  label: 'Choose language',
                  expand: false,
                  onPressed: () => context.pushNamed(AppRoutes.chooseLanguage),
                ),
              )
            : AsyncContent<(Language?, List<Topic>)>(
                key: ValueKey(code),
                load: () async {
                  final repo = context.read<ContentRepository>();
                  return (
                    await repo.getLanguage(code),
                    await repo.getTopics(code),
                  );
                },
                builder: (context, data, reload) => RefreshIndicator(
                  onRefresh: () async => reload(),
                  child: _HomeContent(language: data.$1, topics: data.$2),
                ),
              ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.language, required this.topics});

  final Language? language;
  final List<Topic> topics;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final code = language?.code ?? '';

    return ListView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      children: [
        ResponsiveCenter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Greeting(language: language),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _StreakCard(days: progress.streak)),
                    const SizedBox(width: 12),
                    const Expanded(child: _DailyGoalCard()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _TodayLessonCard(done: progress.dailyLessonDoneToday),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Sections'),
              Row(
                children: [
                  Expanded(
                    child: SectionCard(
                      title: 'Vocabulary',
                      subtitle: '${progress.learnedCount(code)} words learned',
                      icon: Icons.translate_rounded,
                      color: AppColors.primary,
                      onTap: () =>
                          context.go('${AppRoutes.learnPath}?tab=vocabulary'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SectionCard(
                      title: 'Grammar',
                      subtitle:
                          '${progress.grammarCompletedCount(code)} lessons done',
                      icon: Icons.auto_stories_rounded,
                      color: AppColors.purple,
                      onTap: () =>
                          context.go('${AppRoutes.learnPath}?tab=grammar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: progress.recentTopicIds.isEmpty
                    ? 'Start learning'
                    : 'Continue learning',
                actionLabel: 'See all',
                onAction: () => context.go(AppRoutes.learnPath),
              ),
            ],
          ),
        ),
        _ContinueLearningList(topics: topics),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.language});
  final Language? language;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final level = context.watch<SettingsProvider>().level;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${DateUtilsX.greeting()}, ${user?.firstName ?? 'learner'} 👋',
                style: context.text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 2),
              Text(
                language == null
                    ? 'Ready to learn?'
                    : 'Learning ${language!.name} ${language!.flag} · ${level.label}',
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.go(AppRoutes.profilePath),
          child: UserAvatar(user: user, radius: 26),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, s, child) =>
                    Transform.scale(scale: s, child: child),
                child: const Text('🔥', style: TextStyle(fontSize: 30)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$days ${days == 1 ? 'day' : 'days'}',
                  style: context.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.streak,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            days == 0 ? 'Start your streak today!' : 'Day streak — keep going!',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard();

  @override
  Widget build(BuildContext context) {
    final todayXp = context.watch<ProgressProvider>().todayXp;
    final goal = context.watch<SettingsProvider>().dailyGoal;
    final reached = todayXp >= goal;

    return AppCard(
      child: Row(
        children: [
          ProgressRing(
            value: todayXp / goal,
            radius: 28,
            lineWidth: 7,
            color: reached ? AppColors.secondary : null,
            center: Icon(
              reached ? Icons.check_rounded : Icons.bolt_rounded,
              color: reached ? AppColors.secondary : context.colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$todayXp/$goal XP',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  reached ? 'Goal reached!' : 'Daily goal',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
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

class _TodayLessonCard extends StatelessWidget {
  const _TodayLessonCard({required this.done});
  final bool done;

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    return AppCard(
      gradient: done ? AppColors.successGradient : AppColors.primaryGradient,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done ? 'Lesson complete ✓' : "Today's Lesson",
                  style: context.text.titleLarge?.copyWith(
                    color: white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  done
                      ? 'Great work! Practice again for extra XP.'
                      : '${AppConstants.dailyLessonWordCount} new words · '
                            'Flashcards · Mini quiz',
                  style: context.text.bodyMedium?.copyWith(
                    color: white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: done ? 'Practice again' : 'Start',
                  icon: Icons.play_arrow_rounded,
                  variant: ButtonVariant.light,
                  expand: false,
                  onPressed: () => context.pushNamed(AppRoutes.dailyLesson),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            done ? Icons.emoji_events_rounded : Icons.school_rounded,
            size: 72,
            color: white.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningList extends StatelessWidget {
  const _ContinueLearningList({required this.topics});
  final List<Topic> topics;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    if (topics.isEmpty) {
      return const EmptyView(
        title: 'No topics yet',
        message: 'New content is coming soon.',
        compact: true,
      );
    }

    // Recently opened topics first, otherwise the first few topics.
    final byId = {for (final t in topics) t.id: t};
    final recent = progress.recentTopicIds
        .map((id) => byId[id])
        .whereType<Topic>()
        .toList();
    final items = recent.isEmpty ? topics.take(4).toList() : recent;

    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => SizedBox(
          width: 160,
          child: TopicCard(
            topic: items[i],
            compact: true,
            progress: progress.topicProgress(items[i]),
            onTap: () => context.pushNamed(
              AppRoutes.wordList,
              pathParameters: {'topicId': items[i].id},
            ),
          ),
        ),
      ),
    );
  }
}
