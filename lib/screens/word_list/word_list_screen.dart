import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/topic.dart';
import '../../models/word.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/state_views.dart';
import '../../widgets/word_card.dart';

enum _Filter { all, learning, learned }

/// Words in a topic, with practice shortcuts and a learned filter.
class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key, required this.topicId});

  final String topicId;

  Future<(Topic, List<Word>)> _load(BuildContext context) async {
    final repo = context.read<ContentRepository>();
    final topic = await repo.getTopic(topicId);
    if (topic == null) throw StateError('Topic $topicId not found');
    return (topic, await repo.getWords(topicId));
  }

  @override
  Widget build(BuildContext context) {
    return AsyncContent<(Topic, List<Word>)>(
      load: () => _load(context),
      loading: Scaffold(appBar: AppBar(), body: const LoadingView()),
      builder: (context, data, _) =>
          _WordListBody(topic: data.$1, words: data.$2),
    );
  }
}

class _WordListBody extends StatefulWidget {
  const _WordListBody({required this.topic, required this.words});

  final Topic topic;
  final List<Word> words;

  @override
  State<_WordListBody> createState() => _WordListBodyState();
}

class _WordListBodyState extends State<_WordListBody> {
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    // Remember for "Continue learning" on Home.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProgressProvider>().visitTopic(widget.topic.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final topic = widget.topic;
    final visible = widget.words.where((w) {
      final learned = progress.isLearned(w.id);
      return switch (_filter) {
        _Filter.all => true,
        _Filter.learning => !learned,
        _Filter.learned => learned,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ResponsiveCenter(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePadding,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopicHeader(
                      topic: topic,
                      progress: progress.topicProgress(topic),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Flashcards',
                            icon: Icons.style_rounded,
                            onPressed: widget.words.isEmpty
                                ? null
                                : () => context.pushNamed(
                                    AppRoutes.flashcards,
                                    pathParameters: {'topicId': topic.id},
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Quiz',
                            icon: Icons.quiz_rounded,
                            variant: ButtonVariant.outlined,
                            onPressed: widget.words.isEmpty
                                ? null
                                : () => context.pushNamed(
                                    AppRoutes.quizSession,
                                    queryParameters: {'topicId': topic.id},
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final f in _Filter.values)
                          ChoiceChip(
                            label: Text(switch (f) {
                              _Filter.all => 'All',
                              _Filter.learning => 'Learning',
                              _Filter.learned => 'Learned',
                            }),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (visible.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  compact: true,
                  icon: _filter == _Filter.learned
                      ? Icons.school_outlined
                      : Icons.celebration_rounded,
                  title: switch (_filter) {
                    _Filter.learned => 'No learned words yet',
                    _Filter.learning => 'You learned every word! 🎉',
                    _Filter.all => 'No words in this topic',
                  },
                  message: _filter == _Filter.learned
                      ? 'Tap the circle next to a word to mark it as learned.'
                      : null,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pagePadding,
                  0,
                  AppConstants.pagePadding,
                  AppConstants.pagePadding,
                ),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final word = visible[i];
                    return WordCard(
                      word: word,
                      color: topic.color,
                      isLearned: progress.isLearned(word.id),
                      onToggleLearned: () => progress.toggleLearned(word),
                      onTap: () => context.pushNamed(
                        AppRoutes.wordDetail,
                        pathParameters: {'wordId': word.id},
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopicHeader extends StatelessWidget {
  const _TopicHeader({required this.topic, required this.progress});
  final Topic topic;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final learned = (progress * topic.wordCount).round();
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: topic.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(topic.icon, color: topic.color, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.somaliTitle,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$learned of ${topic.wordCount} words learned',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ProgressRing(value: progress, radius: 28, color: topic.color),
        ],
      ),
    );
  }
}
