import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../models/quiz_question.dart';
import '../../widgets/app_card.dart';
import '../../widgets/celebration_confetti.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/state_views.dart';

/// Score, counts, XP and confetti (when passed).
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.result});

  /// `null` if the page was opened without a result (e.g. web refresh).
  final QuizResult? result;

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) {
      return Scaffold(
        body: ErrorView(
          title: 'No result to show',
          message: 'Take a quiz to see your score here.',
          onRetry: () => context.goNamed(AppRoutes.quiz),
        ),
      );
    }

    final color = r.passed ? AppColors.secondary : AppColors.warning;

    return Scaffold(
      body: SafeArea(
        child: CelebrationConfetti(
          play: r.passed,
          child: ResponsiveCenter(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: ProgressRing(
                          value: r.scorePercent / 100,
                          radius: 80,
                          lineWidth: 14,
                          color: color,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${r.scorePercent}%',
                                style: context.text.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                              Text('Score', style: context.text.bodyMedium),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        r.passed ? 'Amazing work! 🎉' : 'Keep practicing! 💪',
                        textAlign: TextAlign.center,
                        style: context.text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.outOfHearts
                            ? 'You ran out of hearts. Review and try again!'
                            : r.passed
                            ? 'You passed the quiz.'
                            : 'Score ${AppConstants.passScore}% or more to pass.',
                        textAlign: TextAlign.center,
                        style: context.text.bodyLarge?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          _ResultStat(
                            value: '${r.correctCount}',
                            label: 'Correct',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 10),
                          _ResultStat(
                            value: '${r.wrongCount}',
                            label: 'Wrong',
                            icon: Icons.cancel_rounded,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 10),
                          _ResultStat(
                            value: '+${r.xpEarned}',
                            label: 'XP earned',
                            icon: Icons.bolt_rounded,
                            color: context.colors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: 'Review answers',
                  icon: Icons.fact_check_rounded,
                  variant: ButtonVariant.outlined,
                  onPressed: r.answers.isEmpty
                      ? null
                      : () => context.pushNamed(AppRoutes.quizReview, extra: r),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Back to Home',
                  onPressed: () => context.goNamed(AppRoutes.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
