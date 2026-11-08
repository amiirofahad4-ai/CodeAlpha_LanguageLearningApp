import 'package:flutter/material.dart';

import '../models/quiz_question.dart';
import 'quiz_option.dart';

/// Two columns: words on the left, Somali meanings on the right (shuffled).
/// Tap one on each side to match. Calls [onCompleted] when every pair is
/// matched, with `true` if there were no mistakes.
class MatchPairsView extends StatefulWidget {
  const MatchPairsView({
    super.key,
    required this.pairs,
    required this.onCompleted,
  });

  final List<MatchPair> pairs;
  final ValueChanged<bool> onCompleted;

  @override
  State<MatchPairsView> createState() => _MatchPairsViewState();
}

class _MatchPairsViewState extends State<MatchPairsView> {
  late final List<String> _left = widget.pairs.map((p) => p.left).toList()
    ..shuffle();
  late final List<String> _right = widget.pairs.map((p) => p.right).toList()
    ..shuffle();
  late final Map<String, String> _answers = {
    for (final p in widget.pairs) p.left: p.right,
  };

  final _matched = <String>{}; // matched left items
  String? _selectedLeft;
  String? _selectedRight;
  (String, String)? _wrongPair;
  int _mistakes = 0;

  void _tapLeft(String value) {
    setState(() => _selectedLeft = value);
    _tryMatch();
  }

  void _tapRight(String value) {
    setState(() => _selectedRight = value);
    _tryMatch();
  }

  Future<void> _tryMatch() async {
    final l = _selectedLeft, r = _selectedRight;
    if (l == null || r == null) return;

    if (_answers[l] == r) {
      setState(() {
        _matched.add(l);
        _selectedLeft = _selectedRight = null;
      });
      if (_matched.length == widget.pairs.length) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        widget.onCompleted(_mistakes == 0);
      }
    } else {
      setState(() {
        _mistakes++;
        _wrongPair = (l, r);
      });
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _wrongPair = null;
        _selectedLeft = _selectedRight = null;
      });
    }
  }

  QuizOptionState _leftState(String v) {
    if (_matched.contains(v)) return QuizOptionState.correct;
    if (_wrongPair?.$1 == v) return QuizOptionState.wrong;
    if (_selectedLeft == v) return QuizOptionState.selected;
    return QuizOptionState.idle;
  }

  QuizOptionState _rightState(String v) {
    if (_matched.any((l) => _answers[l] == v)) return QuizOptionState.correct;
    if (_wrongPair?.$2 == v) return QuizOptionState.wrong;
    if (_selectedRight == v) return QuizOptionState.selected;
    return QuizOptionState.idle;
  }

  Widget _column(
    List<String> items,
    QuizOptionState Function(String) stateOf,
    void Function(String) onTap,
  ) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QuizOption(
              label: item,
              center: true,
              state: stateOf(item),
              onTap:
                  stateOf(item) == QuizOptionState.correct || _wrongPair != null
                  ? null
                  : () => onTap(item),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _column(_left, _leftState, _tapLeft)),
        const SizedBox(width: 12),
        Expanded(child: _column(_right, _rightState, _tapRight)),
      ],
    );
  }
}
