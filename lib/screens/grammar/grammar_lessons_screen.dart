import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/grammar_lesson.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/state_views.dart';

/// List of grammar lessons. Lessons above the user's level are locked.
class GrammarLessonsView extends StatelessWidget {
  const GrammarLessonsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final code = settings.languageCode;
    if (code == null) {
      return const EmptyView(title: 'No language selected');
    }

    return AsyncContent<List<GrammarLesson>>(
      key: ValueKey(code),
      load: () => context.read<ContentRepository>().getGrammarLessons(code),
      isEmpty: (l) => l.isEmpty,
      emptyTitle: 'No grammar lessons yet',
      emptyMessage: 'Grammar for this language is coming soon.',
      emptyIcon: Icons.auto_stories_rounded,
      builder: (context, lessons, _) {
        final progress = context.watch<ProgressProvider>();
        return ResponsiveCenter(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pagePadding,
              4,
              AppConstants.pagePadding,
              AppConstants.pagePadding,
            ),
            itemCount: lessons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final lesson = lessons[i];
              final locked = lesson.level.index > settings.level.index;
              return _GrammarLessonTile(
                lesson: lesson,
                locked: locked,
                completed: progress.isGrammarCompleted(lesson.id),
                onTap: locked
                    ? () => context.showSnack(
                        'Reach ${lesson.level.label} level to unlock this lesson. '
                        'You can change your level in Profile.',
                      )
                    : () => context.pushNamed(
                        AppRoutes.grammarDetail,
                        pathParameters: {'lessonId': lesson.id},
                      ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GrammarLessonTile extends StatelessWidget {
  const _GrammarLessonTile({
    required this.lesson,
    required this.locked,
    required this.completed,
    required this.onTap,
  });

  final GrammarLesson lesson;
  final bool locked;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = LevelBadge.colorOf(lesson.level);
    return Opacity(
      opacity: locked ? 0.6 : 1,
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${lesson.order}',
                style: context.text.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lesson.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LevelBadge(level: lesson.level),
                ],
              ),
            ),
            Icon(
              locked
                  ? Icons.lock_rounded
                  : completed
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: locked
                  ? context.colors.onSurfaceVariant
                  : completed
                  ? AppColors.secondary
                  : context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
