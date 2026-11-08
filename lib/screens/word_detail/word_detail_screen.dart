import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/services/tts_service.dart';
import '../../models/word.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/speaker_button.dart';
import '../../widgets/word_image.dart';

/// Big word, phonetic, translation, example, image and audio.
class WordDetailScreen extends StatelessWidget {
  const WordDetailScreen({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AsyncContent<Word?>(
        load: () => context.read<ContentRepository>().getWord(wordId),
        isEmpty: (w) => w == null,
        emptyTitle: 'Word not found',
        emptyMessage: 'This word may have been removed.',
        emptyIcon: Icons.search_off_rounded,
        builder: (context, word, _) => _WordDetailBody(word: word!),
      ),
    );
  }
}

class _WordDetailBody extends StatelessWidget {
  const _WordDetailBody({required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final learned = progress.isLearned(word.id);

    return SafeArea(
      top: false,
      child: ResponsiveCenter(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.pagePadding,
                ),
                children: [
                  Center(
                    child: Hero(
                      tag: 'word-${word.id}',
                      child: WordImage(word: word, size: 140),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    word.text,
                    textAlign: TextAlign.center,
                    style: context.text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.phonetic,
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: PrimaryButton(
                      label: 'Play audio',
                      icon: Icons.volume_up_rounded,
                      variant: ButtonVariant.outlined,
                      expand: false,
                      onPressed: () async {
                        final ok = await context.read<TtsService>().speak(
                          word.text,
                          word.languageCode,
                        );
                        if (!ok && context.mounted) {
                          context.showSnack(
                            'Audio is not available.',
                            isError: true,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _InfoCard(
                    label: 'Somali translation',
                    icon: Icons.translate_rounded,
                    child: Text(
                      word.translation,
                      style: context.text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    label: 'Example',
                    icon: Icons.format_quote_rounded,
                    trailing: SpeakerButton(
                      text: word.example,
                      languageCode: word.languageCode,
                      size: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.example,
                          style: context.text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.exampleTranslation,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: PrimaryButton(
                label: learned ? 'Learned ✓' : 'Mark as learned',
                icon: learned ? null : Icons.check_rounded,
                variant: learned
                    ? ButtonVariant.success
                    : ButtonVariant.primary,
                onPressed: () async {
                  await progress.toggleLearned(word);
                  if (!learned && context.mounted) {
                    context.showSnack(
                      '+${AppConstants.xpPerLearnedWord} XP · "${word.text}" learned!',
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String label;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      label.toUpperCase(),
                      style: context.text.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
