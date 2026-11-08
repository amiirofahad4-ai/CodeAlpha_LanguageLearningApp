import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/constants.dart';
import '../core/utils/context_ext.dart';
import '../models/word.dart';
import 'speaker_button.dart';
import 'word_image.dart';

/// A flip card. Front = word + pronunciation, back = Somali translation and
/// example. Tap anywhere to flip.
class Flashcard extends StatelessWidget {
  const Flashcard({super.key, required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      speed: 450,
      front: _FlashcardFace(
        color: context.colors.surface,
        border: context.isDark ? context.colors.outline : null,
        child: _Front(word: word),
      ),
      back: _FlashcardFace(
        gradient: AppColors.primaryGradient,
        child: _Back(word: word),
      ),
    );
  }
}

class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace({
    required this.child,
    this.color,
    this.gradient,
    this.border,
  });

  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppConstants.radius * 1.5),
        border: border == null ? null : Border.all(color: border!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Front extends StatelessWidget {
  const _Front({required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: SpeakerButton(
            text: word.text,
            languageCode: word.languageCode,
          ),
        ),
        const Spacer(),
        WordImage(word: word, size: 104),
        const SizedBox(height: 24),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            word.text,
            style: context.text.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          word.phonetic,
          style: context.text.titleMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 18,
              color: context.colors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Tap to flip',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Back extends StatelessWidget {
  const _Back({required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    final muted = white.withValues(alpha: 0.8);
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: SpeakerButton(
            text: word.example,
            languageCode: word.languageCode,
            color: white,
          ),
        ),
        const Spacer(),
        Text(
          'SOMALI',
          style: context.text.labelMedium?.copyWith(
            color: muted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          word.translation,
          textAlign: TextAlign.center,
          style: context.text.headlineMedium?.copyWith(
            color: white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppConstants.radius),
          ),
          child: Column(
            children: [
              Text(
                word.example,
                textAlign: TextAlign.center,
                style: context.text.titleMedium?.copyWith(
                  color: white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                word.exampleTranslation,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: muted),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
