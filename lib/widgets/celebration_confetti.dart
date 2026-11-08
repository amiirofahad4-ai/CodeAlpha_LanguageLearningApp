import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Overlays [child] with a confetti burst that plays once when shown
/// (if [play] is true).
class CelebrationConfetti extends StatefulWidget {
  const CelebrationConfetti({super.key, required this.child, this.play = true});

  final Widget child;
  final bool play;

  @override
  State<CelebrationConfetti> createState() => _CelebrationConfettiState();
}

class _CelebrationConfettiState extends State<CelebrationConfetti> {
  final _controller = ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    if (widget.play) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.play());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controller,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            emissionFrequency: 0.06,
            maxBlastForce: 22,
            minBlastForce: 8,
            gravity: 0.25,
            colors: AppColors.confetti,
          ),
        ),
      ],
    );
  }
}
