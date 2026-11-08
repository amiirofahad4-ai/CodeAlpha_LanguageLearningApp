import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../grammar/grammar_lessons_screen.dart';
import '../vocabulary/vocabulary_topics_screen.dart';

/// "Learn" tab with two sections: Vocabulary and Grammar.
///
/// Open a specific tab with `/learn?tab=grammar`.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, this.initialTab});

  final String? initialTab;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: _indexOf(widget.initialTab),
  );

  static int _indexOf(String? tab) => tab == 'grammar' ? 1 : 0;

  @override
  void didUpdateWidget(LearnScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tabs.animateTo(_indexOf(widget.initialTab));
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 48,
            margin: const EdgeInsets.fromLTRB(
              AppConstants.pagePadding,
              0,
              AppConstants.pagePadding,
              12,
            ),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radius),
            ),
            child: TabBar(
              controller: _tabs,
              indicator: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(AppConstants.radius - 4),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              unselectedLabelColor: context.colors.onSurfaceVariant,
              tabs: const [
                Tab(text: 'Vocabulary'),
                Tab(text: 'Grammar'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [VocabularyTopicsView(), GrammarLessonsView()],
      ),
    );
  }
}
