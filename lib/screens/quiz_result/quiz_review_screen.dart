import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../models/quiz_question.dart';
import '../../widgets/app_card.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/state_views.dart';

/// Lists every question with the user's answer and the correct answer.
class QuizReviewScreen extends StatelessWidget {
  const QuizReviewScreen({super.key, required this.result});

  final QuizResult? result;

  @override
  Widget build(BuildContext context) {
    final answers = result?.answers ?? const <QuizAnswer>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Review answers')),
      body: answers.isEmpty
          ? const EmptyView(
              title: 'Nothing to review',
              message: 'Answer some questions first.',
              icon: Icons.fact_check_outlined,
            )
          : ResponsiveCenter(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                itemCount: answers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _AnswerCard(index: i + 1, answer: answers[i]),
              ),
            ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.index, required this.answer});

  final int index;
  final QuizAnswer answer;

  @override
  Widget build(BuildContext context) {
    final q = answer.question;
    final color = answer.isCorrect ? AppColors.secondary : AppColors.error;

    return AppCard(
      borderColor: color.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                answer.isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                'Question $index · ${q.type.label}',
                style: context.text.labelLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.prompt,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (q.sentence != null)
            Text(q.sentence!, style: context.text.bodyLarge),
          if (q.audioText != null)
            Text('🔊 ${q.audioText}', style: context.text.bodyLarge),
          const SizedBox(height: 10),
          if (!answer.isCorrect)
            _line(
              context,
              'Your answer',
              answer.userAnswer ?? '—',
              AppColors.error,
            ),
          _line(
            context,
            'Correct answer',
            q.correctAnswer,
            AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: value,
              style: context.text.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
