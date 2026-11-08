import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/grammar_lesson.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/quiz_option.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/section_card.dart';
import '../../widgets/speaker_button.dart';

/// Explanation, highlighted rule, examples table and a practice exercise.
class GrammarLessonDetailScreen extends StatelessWidget {
  const GrammarLessonDetailScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar')),
      body: AsyncContent<GrammarLesson?>(
        load: () =>
            context.read<ContentRepository>().getGrammarLesson(lessonId),
        isEmpty: (l) => l == null,
        emptyTitle: 'Lesson not found',
        emptyIcon: Icons.search_off_rounded,
        builder: (context, lesson, _) => _LessonBody(lesson: lesson!),
      ),
    );
  }
}

class _LessonBody extends StatelessWidget {
  const _LessonBody({required this.lesson});
  final GrammarLesson lesson;

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.pagePadding,
          0,
          AppConstants.pagePadding,
          32,
        ),
        children: [
          LevelBadge(level: lesson.level).alignLeft(),
          const SizedBox(height: 10),
          Text(
            lesson.title,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            lesson.description,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            lesson.explanation,
            style: context.text.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 20),
          _RuleBox(rule: lesson.rule),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Examples'),
          _ExamplesTable(lesson: lesson),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Practice'),
          _Practice(lesson: lesson),
        ],
      ),
    );
  }
}

extension on Widget {
  Widget alignLeft() => Align(alignment: Alignment.centerLeft, child: this);
}

class _RuleBox extends StatelessWidget {
  const _RuleBox({required this.rule});
  final String rule;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radius),
        border: Border(left: BorderSide(color: color, width: 5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RULE',
                  style: context.text.labelMedium?.copyWith(
                    color: color,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rule,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamplesTable extends StatelessWidget {
  const _ExamplesTable({required this.lesson});
  final GrammarLesson lesson;

  @override
  Widget build(BuildContext context) {
    final header = context.text.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: context.colors.onSurfaceVariant,
    );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.1),
          1: FlexColumnWidth(1),
          2: FixedColumnWidth(48),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder(
          horizontalInside: BorderSide(color: context.colors.outline),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radius),
              ),
            ),
            children: [
              _cell(Text('Sentence', style: header)),
              _cell(Text('Somali', style: header)),
              const SizedBox.shrink(),
            ],
          ),
          for (final e in lesson.examples)
            TableRow(
              children: [
                _cell(
                  Text(
                    e.sentence,
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _cell(
                  Text(
                    e.translation,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                SpeakerButton(
                  text: e.sentence,
                  languageCode: lesson.languageCode,
                  size: 36,
                  filled: false,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(Widget child) =>
      Padding(padding: const EdgeInsets.all(12), child: child);
}

/// One multiple-choice question; completing it marks the lesson done.
class _Practice extends StatefulWidget {
  const _Practice({required this.lesson});
  final GrammarLesson lesson;

  @override
  State<_Practice> createState() => _PracticeState();
}

class _PracticeState extends State<_Practice> {
  int? _selected;
  bool _checked = false;

  GrammarExercise get _ex => widget.lesson.exercise;
  bool get _isCorrect => _selected == _ex.correctIndex;

  Future<void> _check() async {
    setState(() => _checked = true);
    if (_isCorrect) {
      final firstTime = await context.read<ProgressProvider>().completeGrammar(
        widget.lesson.id,
      );
      if (firstTime && mounted) {
        context.showSnack(
          'Lesson complete! +${AppConstants.xpGrammarLesson} XP',
        );
      }
    }
  }

  QuizOptionState _state(int i) {
    if (!_checked) {
      return _selected == i ? QuizOptionState.selected : QuizOptionState.idle;
    }
    if (i == _ex.correctIndex) return QuizOptionState.correct;
    if (i == _selected) return QuizOptionState.wrong;
    return QuizOptionState.disabled;
  }

  @override
  Widget build(BuildContext context) {
    final completed = context.watch<ProgressProvider>().isGrammarCompleted(
      widget.lesson.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (completed && !_checked)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'You completed this lesson',
                  style: context.text.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        Text(
          _ex.prompt,
          style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _ex.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QuizOption(
              label: _ex.options[i],
              leading: String.fromCharCode(65 + i),
              state: _state(i),
              onTap: _checked ? null : () => setState(() => _selected = i),
            ),
          ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: _checked
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_isCorrect ? AppColors.secondary : AppColors.error)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radius),
                  ),
                  child: Text(
                    '${_isCorrect ? 'Correct! ' : 'Not quite. '}${_ex.explanation}',
                    style: context.text.bodyMedium?.copyWith(
                      color: _isCorrect ? AppColors.secondary : AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 8),
        _checked
            ? PrimaryButton(
                label: _isCorrect ? 'Practice again' : 'Try again',
                icon: Icons.replay_rounded,
                variant: ButtonVariant.outlined,
                onPressed: () => setState(() {
                  _checked = false;
                  _selected = null;
                }),
              )
            : PrimaryButton(
                label: 'Check answer',
                onPressed: _selected == null ? null : _check,
              ),
      ],
    );
  }
}
