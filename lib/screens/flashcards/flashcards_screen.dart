import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/word.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/celebration_confetti.dart';
import '../../widgets/flashcard_deck.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/responsive_center.dart';

/// Flashcard practice for a topic, followed by a summary.
class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcards')),
      body: SafeArea(
        top: false,
        child: AsyncContent<List<Word>>(
          load: () => context.read<ContentRepository>().getWords(topicId),
          isEmpty: (w) => w.isEmpty,
          emptyTitle: 'No cards to practice',
          emptyMessage: 'This topic has no words yet.',
          emptyIcon: Icons.style_outlined,
          builder: (context, words, _) => _FlashcardsSession(words: words),
        ),
      ),
    );
  }
}

class _FlashcardsSession extends StatefulWidget {
  const _FlashcardsSession({required this.words});
  final List<Word> words;

  @override
  State<_FlashcardsSession> createState() => _FlashcardsSessionState();
}

class _FlashcardsSessionState extends State<_FlashcardsSession> {
  late List<Word> _deck = [...widget.words]..shuffle();
  List<Word>? _known;
  List<Word>? _unknown;
  int _round = 0; // bump to rebuild the deck

  Future<void> _finish(List<Word> known, List<Word> unknown) async {
    final progress = context.read<ProgressProvider>();
    await progress.markLearned(known);
    await progress.addXp(known.length * AppConstants.xpPerKnownFlashcard);
    setState(() {
      _known = known;
      _unknown = unknown;
    });
  }

  void _restart(List<Word> words) => setState(() {
    _deck = [...words]..shuffle();
    _known = _unknown = null;
    _round++;
  });

  @override
  Widget build(BuildContext context) {
    final known = _known, unknown = _unknown;
    return ResponsiveCenter(
      maxWidth: 520,
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: known == null || unknown == null
            ? FlashcardDeck(
                key: ValueKey(_round),
                words: _deck,
                onFinished: _finish,
              )
            : FlashcardSummary(
                known: known,
                unknown: unknown,
                onReviewUnknown: unknown.isEmpty
                    ? null
                    : () => _restart(unknown),
                onRestart: () => _restart(widget.words),
                onDone: () => context.pop(),
              ),
      ),
    );
  }
}

/// End-of-deck summary. Also used by the Daily Lesson.
class FlashcardSummary extends StatelessWidget {
  const FlashcardSummary({
    super.key,
    required this.known,
    required this.unknown,
    required this.onDone,
    this.onReviewUnknown,
    this.onRestart,
    this.doneLabel = 'Done',
  });

  final List<Word> known;
  final List<Word> unknown;
  final VoidCallback onDone;
  final VoidCallback? onReviewUnknown;
  final VoidCallback? onRestart;
  final String doneLabel;

  @override
  Widget build(BuildContext context) {
    final total = known.length + unknown.length;
    final ratio = total == 0 ? 0.0 : known.length / total;

    return CelebrationConfetti(
      play: ratio >= 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 8),
                Center(
                  child: ProgressRing(
                    value: ratio,
                    radius: 64,
                    lineWidth: 12,
                    color: AppColors.secondary,
                    center: Text(
                      '${known.length}/$total',
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  ratio >= 0.7 ? 'Great job! 🎉' : 'Keep practicing 💪',
                  textAlign: TextAlign.center,
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You knew ${known.length} of $total cards',
                  textAlign: TextAlign.center,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _CountTile(
                        count: known.length,
                        label: 'I know',
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CountTile(
                        count: unknown.length,
                        label: "Don't know",
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
                if (unknown.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Words to review',
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final w in unknown)
                        Chip(label: Text('${w.text} · ${w.translation}')),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onReviewUnknown != null) ...[
            PrimaryButton(
              label: 'Review unknown words',
              icon: Icons.replay_rounded,
              variant: ButtonVariant.outlined,
              onPressed: onReviewUnknown,
            ),
            const SizedBox(height: 12),
          ] else if (onRestart != null) ...[
            PrimaryButton(
              label: 'Practice again',
              icon: Icons.replay_rounded,
              variant: ButtonVariant.outlined,
              onPressed: onRestart,
            ),
            const SizedBox(height: 12),
          ],
          PrimaryButton(label: doneLabel, onPressed: onDone),
        ],
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.count,
    required this.label,
    required this.color,
  });

  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withValues(alpha: 0.1),
      child: Column(
        children: [
          Text(
            '$count',
            style: context.text.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: context.text.bodyMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}
