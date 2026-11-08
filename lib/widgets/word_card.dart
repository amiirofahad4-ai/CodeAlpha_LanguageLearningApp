import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/utils/context_ext.dart';
import '../models/word.dart';
import 'app_card.dart';
import 'speaker_button.dart';
import 'word_image.dart';

/// A row in a word list: picture, word, Somali translation, speaker and
/// a "learned" checkmark.
class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.isLearned,
    this.onTap,
    this.onToggleLearned,
    this.color,
  });

  final Word word;
  final bool isLearned;
  final VoidCallback? onTap;
  final VoidCallback? onToggleLearned;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      child: Row(
        children: [
          WordImage(word: word, size: 52, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.text,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  word.translation,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SpeakerButton(text: word.text, languageCode: word.languageCode),
          IconButton(
            tooltip: isLearned ? 'Mark as not learned' : 'Mark as learned',
            onPressed: onToggleLearned,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isLearned
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(isLearned),
                color: isLearned
                    ? AppColors.secondary
                    : context.colors.onSurfaceVariant,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
