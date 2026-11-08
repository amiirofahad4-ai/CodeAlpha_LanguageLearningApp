import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/quiz_question.dart';
import '../../models/word.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_content.dart';
import '../../widgets/celebration_confetti.dart';
import '../../widgets/flashcard_deck.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/quiz_session.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/speaker_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/word_image.dart';

enum _Step { newWords, flashcards, quiz, complete }

/// Step-by-step lesson: new words → flashcards → mini quiz → completion.
class DailyLessonScreen extends StatelessWidget {
  const DailyLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final code = context.read<SettingsProvider>().languageCode;
    final learned = context.read<ProgressProvider>().progress.learnedWordIds;
    final repo = context.read<ContentRepository>();

    return Scaffold(
      body: SafeArea(
        child: code == null
            ? const ErrorView(
                title: 'No language selected',
                message: 'Choose a language before starting a lesson.',
              )
            : AsyncContent<(List<Word>, List<QuizQuestion>)>(
                load: () async {
                  var words = await repo.getDailyLessonWords(
                    code,
                    learnedIds: learned,
                  );
                  // Everything learned? Review random words instead.
                  if (words.isEmpty) {
                    final all = await repo.getAllWords(code);
                    words = (all..shuffle())
                        .take(AppConstants.dailyLessonWordCount)
                        .toList();
                  }
                  final quiz = await repo.getQuizForWords(words);
                  return (words, quiz);
                },
                isEmpty: (d) => d.$1.isEmpty,
                emptyTitle: 'No lesson available',
                emptyMessage: 'There is no content for this language yet.',
                emptyAction: PrimaryButton(
                  label: 'Back to Home',
                  expand: false,
                  onPressed: () => context.goNamed(AppRoutes.home),
                ),
                builder: (context, data, _) =>
                    _LessonFlow(words: data.$1, questions: data.$2),
              ),
      ),
    );
  }
}

class _LessonFlow extends StatefulWidget {
  const _LessonFlow({required this.words, required this.questions});

  final List<Word> words;
  final List<QuizQuestion> questions;

  @override
  State<_LessonFlow> createState() => _LessonFlowState();
}

class _LessonFlowState extends State<_LessonFlow> {
  _Step _step = _Step.newWords;
  QuizResult? _result;
  int _xpEarned = 0;

  void _go(_Step step) => setState(() => _step = step);

  Future<void> _onFlashcardsDone(List<Word> known, List<Word> unknown) async {
    final progress = context.read<ProgressProvider>();
    final newlyLearned = known.where((w) => !progress.isLearned(w.id)).length;
    await progress.markLearned(known);
    _xpEarned += newlyLearned * AppConstants.xpPerLearnedWord;
    _go(_Step.quiz);
  }

  Future<void> _onQuizDone(QuizResult result) async {
    final progress = context.read<ProgressProvider>();
    await progress.recordQuiz(result);
    await progress.completeDailyLesson(
      bonusXp: AppConstants.xpDailyLessonBonus,
    );
    _xpEarned += result.xpEarned + AppConstants.xpDailyLessonBonus;
    _result = result;
    _go(_Step.complete);
  }

  Future<void> _confirmExit() async {
    if (_step == _Step.complete) {
      context.pop();
      return;
    }
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave lesson?'),
        content: const Text('Your progress in this lesson will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == _Step.complete,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Column(
        children: [
          if (_step != _Step.quiz)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _confirmExit,
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(child: _StepIndicator(current: _step)),
                ],
              ),
            ),
          if (_step == _Step.quiz) const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0.1, 0),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.newWords:
        return _NewWordsStep(
          words: widget.words,
          onDone: () => _go(_Step.flashcards),
        );
      case _Step.flashcards:
        return ResponsiveCenter(
          maxWidth: 520,
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: FlashcardDeck(
            words: widget.words,
            onFinished: _onFlashcardsDone,
          ),
        );
      case _Step.quiz:
        return ResponsiveCenter(
          child: widget.questions.isEmpty
              ? EmptyView(
                  title: 'No quiz today',
                  action: PrimaryButton(
                    label: 'Finish',
                    expand: false,
                    onPressed: () => _onQuizDone(
                      const QuizResult(answers: [], totalQuestions: 0),
                    ),
                  ),
                )
              : QuizSession(
                  questions: widget.questions,
                  onClose: _confirmExit,
                  onFinished: _onQuizDone,
                ),
        );
      case _Step.complete:
        return _CompleteStep(result: _result, xpEarned: _xpEarned);
    }
  }
}

/// Four dots/bars showing where the user is in the lesson.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});
  final _Step current;

  static const _labels = ['Words', 'Cards', 'Quiz', 'Done'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final step in _Step.values) ...[
          Expanded(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  decoration: BoxDecoration(
                    color: step.index <= current.index
                        ? AppColors.secondary
                        : context.colors.outline,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[step.index],
                  style: context.text.labelSmall?.copyWith(
                    color: step == current
                        ? context.colors.onSurface
                        : context.colors.onSurfaceVariant,
                    fontWeight: step == current
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (step != _Step.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

/// Swipe through the new words one by one.
class _NewWordsStep extends StatefulWidget {
  const _NewWordsStep({required this.words, required this.onDone});

  final List<Word> words;
  final VoidCallback onDone;

  @override
  State<_NewWordsStep> createState() => _NewWordsStepState();
}

class _NewWordsStepState extends State<_NewWordsStep> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == widget.words.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 520,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.pagePadding,
            ),
            child: Text(
              'New words (${_page + 1}/${widget.words.length})',
              style: context.text.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.words.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                child: _NewWordCard(word: widget.words[i]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.pagePadding,
              0,
              AppConstants.pagePadding,
              AppConstants.pagePadding,
            ),
            child: PrimaryButton(
              label: _isLast ? 'Practice with flashcards' : 'Next word',
              icon: _isLast ? Icons.style_rounded : Icons.arrow_forward_rounded,
              onPressed: _isLast
                  ? widget.onDone
                  : () => _controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewWordCard extends StatelessWidget {
  const _NewWordCard({required this.word});
  final Word word;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            WordImage(word: word, size: 112),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    word.text,
                    textAlign: TextAlign.center,
                    style: context.text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SpeakerButton(text: word.text, languageCode: word.languageCode),
              ],
            ),
            Text(
              word.phonetic,
              style: context.text.titleSmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              word.translation,
              textAlign: TextAlign.center,
              style: context.text.titleLarge?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 40),
            Text(
              word.example,
              textAlign: TextAlign.center,
              style: context.text.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              word.exampleTranslation,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({required this.result, required this.xpEarned});

  final QuizResult? result;
  final int xpEarned;

  @override
  Widget build(BuildContext context) {
    final streak = context.watch<ProgressProvider>().streak;

    return CelebrationConfetti(
      child: ResponsiveCenter(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Column(
          children: [
            const Spacer(),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (_, s, child) => Transform.scale(scale: s, child: child),
              child: const Text('🏆', style: TextStyle(fontSize: 96)),
            ),
            const SizedBox(height: 16),
            Text(
              'Lesson complete!',
              style: context.text.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              result == null || result!.totalQuestions == 0
                  ? 'Well done!'
                  : 'Quiz score: ${result!.scorePercent}%',
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _RewardTile(
                    emoji: '⚡',
                    value: '+$xpEarned XP',
                    label: 'Earned',
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RewardTile(
                    emoji: '🔥',
                    value: '$streak ${streak == 1 ? 'day' : 'days'}',
                    label: 'Streak',
                    color: AppColors.streak,
                  ),
                ),
              ],
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Back to Home',
              onPressed: () => context.goNamed(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  final String emoji;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: color.withValues(alpha: 0.5),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            value,
            style: context.text.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
