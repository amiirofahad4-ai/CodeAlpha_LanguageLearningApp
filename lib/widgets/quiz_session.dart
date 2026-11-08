import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/constants.dart';
import '../core/utils/context_ext.dart';
import '../data/services/tts_service.dart';
import '../models/quiz_question.dart';
import 'app_card.dart';
import 'app_progress_bar.dart';
import 'feedback_sheet.dart';
import 'match_pairs.dart';
import 'primary_button.dart';
import 'quiz_option.dart';
import 'speaker_button.dart';

/// Runs a list of quiz questions: progress bar, counter, hearts,
/// instant feedback, and a [QuizResult] at the end.
///
/// Used by the Quiz screen and by the Daily Lesson's mini quiz.
class QuizSession extends StatefulWidget {
  const QuizSession({
    super.key,
    required this.questions,
    required this.onFinished,
    this.maxHearts,
    this.onClose,
  });

  final List<QuizQuestion> questions;
  final ValueChanged<QuizResult> onFinished;

  /// `null` = no lives (unlimited mistakes).
  final int? maxHearts;
  final VoidCallback? onClose;

  @override
  State<QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends State<QuizSession> {
  int _index = 0;
  late int _hearts = widget.maxHearts ?? 0;
  final _answers = <QuizAnswer>[];
  int? _selected;
  bool _checking = false;

  QuizQuestion get _question => widget.questions[_index];
  int get _total => widget.questions.length;

  Future<void> _check() async {
    final selected = _selected;
    if (selected == null || _checking) return;
    await _record(
      correct: selected == _question.correctIndex,
      userAnswer: _question.options[selected],
    );
  }

  Future<void> _record({
    required bool correct,
    required String userAnswer,
  }) async {
    setState(() {
      _checking = true;
      _answers.add(
        QuizAnswer(
          question: _question,
          userAnswer: userAnswer,
          isCorrect: correct,
        ),
      );
      if (!correct && widget.maxHearts != null) _hearts--;
    });

    await showAnswerFeedback(
      context,
      correct: correct,
      correctAnswer: _question.correctAnswer,
    );
    if (!mounted) return;

    final outOfHearts = widget.maxHearts != null && _hearts <= 0;
    if (outOfHearts || _index == _total - 1) {
      widget.onFinished(
        QuizResult(
          answers: List.unmodifiable(_answers),
          totalQuestions: _total,
          outOfHearts: outOfHearts && _index < _total - 1,
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _checking = false;
    });
  }

  QuizOptionState _optionState(int i) {
    if (!_checking) {
      return _selected == i ? QuizOptionState.selected : QuizOptionState.idle;
    }
    if (i == _question.correctIndex) return QuizOptionState.correct;
    if (i == _selected) return QuizOptionState.wrong;
    return QuizOptionState.disabled;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return const SizedBox.shrink();
    final isMatch = _question.type == QuizType.matchPairs;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: close · progress · hearts
          Row(
            children: [
              if (widget.onClose != null)
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Quit',
                ),
              Expanded(
                child: AppProgressBar(
                  value: (_index + (_checking ? 1 : 0)) / _total,
                  color: AppColors.secondary,
                  height: 12,
                ),
              ),
              if (widget.maxHearts != null) ...[
                const SizedBox(width: 12),
                _Hearts(count: _hearts),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Question ${_index + 1} of $_total · ${_question.type.label}',
            style: context.text.labelLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              // Keep the question pinned to the top (default is centered).
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: SingleChildScrollView(
                key: ValueKey(_index),
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildQuestion(),
              ),
            ),
          ),
          if (!isMatch)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PrimaryButton(
                label: 'Check',
                onPressed: _selected == null || _checking ? null : _check,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          q.prompt,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        if (q.type == QuizType.listenAndChoose) ...[
          _ListenPrompt(text: q.audioText ?? '', languageCode: q.languageCode),
          const SizedBox(height: 24),
        ],
        if (q.type == QuizType.fillInBlank) ...[
          _SentenceCard(sentence: q.sentence ?? '', hint: q.hint),
          const SizedBox(height: 24),
        ],
        if (q.type == QuizType.matchPairs)
          MatchPairsView(
            key: ValueKey(q.id),
            pairs: q.pairs,
            onCompleted: (perfect) => _record(
              correct: perfect,
              userAnswer: perfect
                  ? 'All pairs matched'
                  : 'Matched with mistakes',
            ),
          )
        else
          for (var i = 0; i < q.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: QuizOption(
                label: q.options[i],
                leading: String.fromCharCode(65 + i), // A, B, C, D
                state: _optionState(i),
                onTap: _checking ? null : () => setState(() => _selected = i),
              ),
            ),
      ],
    );
  }
}

class _Hearts extends StatelessWidget {
  const _Hearts({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.favorite_rounded, color: AppColors.error, size: 26),
        const SizedBox(width: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Text(
            '$count',
            key: ValueKey(count),
            style: context.text.titleMedium?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Big speaker that auto-plays once when the question appears.
class _ListenPrompt extends StatefulWidget {
  const _ListenPrompt({required this.text, required this.languageCode});
  final String text;
  final String languageCode;

  @override
  State<_ListenPrompt> createState() => _ListenPromptState();
}

class _ListenPromptState extends State<_ListenPrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TtsService>().speak(widget.text, widget.languageCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SpeakerButton(
            text: widget.text,
            languageCode: widget.languageCode,
            size: 96,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to listen again',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentenceCard extends StatelessWidget {
  const _SentenceCard({required this.sentence, this.hint});
  final String sentence;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final parts = sentence.split('_____');
    final style = context.text.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: style,
              children: [
                for (var i = 0; i < parts.length; i++) ...[
                  TextSpan(text: parts[i]),
                  if (i < parts.length - 1)
                    TextSpan(
                      text: ' ______ ',
                      style: style?.copyWith(color: context.colors.primary),
                    ),
                ],
              ],
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.translate_rounded,
                  size: 16,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hint!,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
