import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/utils/context_ext.dart';
import '../models/word.dart';
import 'app_progress_bar.dart';
import 'flashcard.dart';
import 'primary_button.dart';

/// A swipeable stack of [Flashcard]s.
///
/// Swipe right (or tap "I know") to mark a card as known, swipe left
/// (or "I don't know") for unknown. Calls [onFinished] after the last card.
/// Used by the Flashcards screen and the Daily Lesson.
class FlashcardDeck extends StatefulWidget {
  const FlashcardDeck({
    super.key,
    required this.words,
    required this.onFinished,
  });

  final List<Word> words;
  final void Function(List<Word> known, List<Word> unknown) onFinished;

  @override
  State<FlashcardDeck> createState() => _FlashcardDeckState();
}

class _FlashcardDeckState extends State<FlashcardDeck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
      )..addListener(
        () => setState(() => _drag = _tween?.evaluate(_curve) ?? _drag),
      );

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _anim,
    curve: Curves.easeOut,
  );

  Tween<Offset>? _tween;
  Offset _drag = Offset.zero;
  int _index = 0;
  final _known = <Word>[];
  final _unknown = <Word>[];

  bool get _isAnimating => _anim.isAnimating;

  @override
  void dispose() {
    _curve.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _animateTo(Offset target) async {
    _tween = Tween(begin: _drag, end: target);
    await _anim.forward(from: 0);
  }

  Future<void> _swipe({required bool known}) async {
    if (_isAnimating || _index >= widget.words.length) return;
    final width = MediaQuery.sizeOf(context).width;
    await _animateTo(Offset((known ? 1 : -1) * width * 1.4, _drag.dy + 40));

    final word = widget.words[_index];
    (known ? _known : _unknown).add(word);
    setState(() {
      _index++;
      _drag = Offset.zero;
    });
    if (_index == widget.words.length) {
      widget.onFinished(List.of(_known), List.of(_unknown));
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (_drag.dx.abs() > width * 0.28 || velocity.abs() > 900) {
      _swipe(known: (_drag.dx + velocity * 0.1) > 0);
    } else {
      _animateTo(Offset.zero); // snap back
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.words.length;
    final done = _index >= total;
    final width = MediaQuery.sizeOf(context).width;
    final dragRatio = (_drag.dx / (width * 0.35)).clamp(-1.0, 1.0);

    return Column(
      children: [
        // Progress indicator, e.g. 4/10
        Row(
          children: [
            Expanded(
              child: AppProgressBar(value: total == 0 ? 0 : _index / total),
            ),
            const SizedBox(width: 12),
            Text(
              '${math.min(_index + 1, total)}/$total',
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: done
              ? const SizedBox.shrink()
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Next card peeking behind
                    if (_index + 1 < total)
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(0, 14 - 14 * dragRatio.abs()),
                          child: Transform.scale(
                            scale: 0.94 + 0.06 * dragRatio.abs(),
                            child: IgnorePointer(
                              child: Flashcard(
                                key: ValueKey(
                                  'next-${widget.words[_index + 1].id}',
                                ),
                                word: widget.words[_index + 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Top card
                    Positioned.fill(
                      child: GestureDetector(
                        onPanUpdate: _isAnimating
                            ? null
                            : (d) => setState(() => _drag += d.delta),
                        onPanEnd: _isAnimating ? null : _onPanEnd,
                        child: Transform.translate(
                          offset: _drag,
                          child: Transform.rotate(
                            angle: _drag.dx / width * 0.35,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Flashcard(
                                    key: ValueKey(widget.words[_index].id),
                                    word: widget.words[_index],
                                  ),
                                ),
                                _SwipeLabel(ratio: dragRatio),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: "I don't know",
                icon: Icons.close_rounded,
                variant: ButtonVariant.danger,
                onPressed: done ? null : () => _swipe(known: false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'I know',
                icon: Icons.check_rounded,
                variant: ButtonVariant.success,
                onPressed: done ? null : () => _swipe(known: true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// "KNOW" / "DON'T KNOW" stamp that fades in while dragging.
class _SwipeLabel extends StatelessWidget {
  const _SwipeLabel({required this.ratio});
  final double ratio;

  @override
  Widget build(BuildContext context) {
    if (ratio.abs() < 0.05) return const SizedBox.shrink();
    final known = ratio > 0;
    final color = known ? AppColors.secondary : AppColors.error;
    return Positioned(
      top: 28,
      left: known ? 24 : null,
      right: known ? null : 24,
      child: Opacity(
        opacity: ratio.abs(),
        child: Transform.rotate(
          angle: known ? -0.2 : 0.2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              known ? 'KNOW' : "DON'T KNOW",
              style: context.text.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
