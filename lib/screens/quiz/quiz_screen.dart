import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../data/repositories/content_repository.dart';
import '../../models/quiz_question.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/async_content.dart';
import '../../widgets/responsive_center.dart';
import '../../widgets/state_views.dart';
import '../../widgets/quiz_session.dart';

/// Plays a quiz (all topics, or one topic when [topicId] is set) with
/// hearts, then opens the result screen.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, this.topicId});

  final String? topicId;

  @override
  Widget build(BuildContext context) {
    final code = context.read<SettingsProvider>().languageCode;

    return Scaffold(
      body: SafeArea(
        child: code == null
            ? const ErrorView(title: 'No language selected')
            : AsyncContent<List<QuizQuestion>>(
                load: () => context.read<ContentRepository>().getQuiz(
                  languageCode: code,
                  topicId: topicId,
                  count: topicId == null ? AppConstants.quizLength : 10,
                ),
                loading: const LoadingView(message: 'Preparing your quiz…'),
                isEmpty: (q) => q.isEmpty,
                emptyTitle: 'No questions yet',
                emptyMessage: 'Learn some words first, then come back!',
                emptyIcon: Icons.quiz_outlined,
                builder: (context, questions, _) =>
                    _QuizRunner(questions: questions),
              ),
      ),
    );
  }
}

class _QuizRunner extends StatelessWidget {
  const _QuizRunner({required this.questions});
  final List<QuizQuestion> questions;

  Future<void> _confirmQuit(BuildContext context) async {
    final quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit quiz?'),
        content: const Text('Your answers will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    if (quit == true && context.mounted) context.pop();
  }

  Future<void> _finish(BuildContext context, QuizResult result) async {
    await context.read<ProgressProvider>().recordQuiz(result);
    if (context.mounted) {
      context.pushReplacementNamed(AppRoutes.quizResult, extra: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmQuit(context);
      },
      child: ResponsiveCenter(
        child: QuizSession(
          questions: questions,
          maxHearts: AppConstants.maxHearts,
          onClose: () => _confirmQuit(context),
          onFinished: (result) => _finish(context, result),
        ),
      ),
    );
  }
}
