import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/utils/context_ext.dart';
import 'primary_button.dart';

/// Shows the green "Correct!" or red "Not quite" bottom sheet.
/// Completes when the user taps Continue.
Future<void> showAnswerFeedback(
  BuildContext context, {
  required bool correct,
  required String correctAnswer,
  String? explanation,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    barrierColor: Colors.black.withValues(alpha: 0.15),
    backgroundColor: Colors.transparent,
    builder: (_) => _FeedbackSheet(
      correct: correct,
      correctAnswer: correctAnswer,
      explanation: explanation,
    ),
  );
}

class _FeedbackSheet extends StatelessWidget {
  const _FeedbackSheet({
    required this.correct,
    required this.correctAnswer,
    this.explanation,
  });

  final bool correct;
  final String correctAnswer;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.secondary : AppColors.error;
    final bg = Color.alphaBlend(
      color.withValues(alpha: context.isDark ? 0.22 : 0.12),
      context.colors.surface,
    );

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: color,
                  child: Icon(
                    correct ? Icons.check_rounded : Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                correct ? 'Correct!' : 'Not quite',
                style: context.text.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (!correct) ...[
            const SizedBox(height: 14),
            Text(
              'Correct answer:',
              style: context.text.labelLarge?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              correctAnswer,
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (explanation != null) ...[
            const SizedBox(height: 10),
            Text(explanation!, style: context.text.bodyMedium),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Continue',
            variant: correct ? ButtonVariant.success : ButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
