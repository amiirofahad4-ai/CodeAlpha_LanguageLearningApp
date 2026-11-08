import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/constants.dart';
import '../core/utils/context_ext.dart';

enum QuizOptionState { idle, selected, correct, wrong, disabled }

/// A large tappable answer tile. Its colour reflects [state].
/// Used by quizzes, match pairs and grammar practice.
class QuizOption extends StatelessWidget {
  const QuizOption({
    super.key,
    required this.label,
    required this.state,
    this.onTap,
    this.leading,
    this.center = false,
  });

  final String label;
  final QuizOptionState state;
  final VoidCallback? onTap;

  /// Usually a letter badge (A, B, C…).
  final String? leading;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final (Color border, Color bg, Color fg) = switch (state) {
      QuizOptionState.idle => (
        scheme.outline,
        scheme.surface,
        scheme.onSurface,
      ),
      QuizOptionState.selected => (
        scheme.primary,
        scheme.primary.withValues(alpha: 0.10),
        scheme.primary,
      ),
      QuizOptionState.correct => (
        AppColors.secondary,
        AppColors.secondary.withValues(alpha: 0.12),
        AppColors.secondary,
      ),
      QuizOptionState.wrong => (
        AppColors.error,
        AppColors.error.withValues(alpha: 0.12),
        AppColors.error,
      ),
      QuizOptionState.disabled => (
        scheme.outline.withValues(alpha: 0.5),
        scheme.surface,
        scheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    };
    final radius = BorderRadius.circular(AppConstants.radius);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Color.alphaBlend(bg, scheme.surface),
        borderRadius: radius,
        border: Border.all(color: border, width: 2),
        boxShadow: [
          // "3D" bottom edge like a physical button
          BoxShadow(color: border, offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: state == QuizOptionState.disabled ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: center
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  if (leading != null) ...[
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border, width: 1.5),
                      ),
                      child: Text(
                        leading!,
                        style: context.text.labelLarge?.copyWith(color: fg),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: center ? TextAlign.center : TextAlign.start,
                      style: context.text.titleMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!center && state == QuizOptionState.correct) ...[
                    const Spacer(),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.secondary,
                    ),
                  ],
                  if (!center && state == QuizOptionState.wrong) ...[
                    const Spacer(),
                    const Icon(Icons.cancel_rounded, color: AppColors.error),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
