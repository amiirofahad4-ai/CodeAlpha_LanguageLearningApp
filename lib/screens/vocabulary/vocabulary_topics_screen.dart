import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/topic.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/async_content.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/state_views.dart';
import '../../widgets/topic_card.dart';

/// Grid of vocabulary topics with % completed. Shown in the Learn tab.
class VocabularyTopicsView extends StatelessWidget {
  const VocabularyTopicsView({super.key});

  @override
  Widget build(BuildContext context) {
    final code = context.watch<SettingsProvider>().languageCode;
    if (code == null) {
      return const EmptyView(
        title: 'No language selected',
        message: 'Choose a language from your profile.',
      );
    }

    return AsyncContent<List<Topic>>(
      key: ValueKey(code),
      load: () => context.read<ContentRepository>().getTopics(code),
      isEmpty: (t) => t.isEmpty,
      emptyTitle: 'No topics yet',
      emptyMessage: 'Vocabulary for this language is coming soon.',
      emptyIcon: Icons.category_rounded,
      builder: (context, topics, _) {
        final progress = context.watch<ProgressProvider>();
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.clamp(
              0.0,
              AppConstants.maxContentWidth,
            );
            return ResponsiveCenter(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pagePadding,
                  4,
                  AppConstants.pagePadding,
                  AppConstants.pagePadding,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: responsiveColumns(width),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  mainAxisExtent: 196,
                ),
                itemCount: topics.length,
                itemBuilder: (context, i) => TopicCard(
                  topic: topics[i],
                  progress: progress.topicProgress(topics[i]),
                  onTap: () => context.pushNamed(
                    AppRoutes.wordList,
                    pathParameters: {'topicId': topics[i].id},
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
