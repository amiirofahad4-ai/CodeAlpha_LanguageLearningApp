import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../core/utils/context_ext.dart';

/// Rounded, animated linear progress bar.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 10,
  });

  /// 0.0 – 1.0
  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.primary;
    return LinearPercentIndicator(
      percent: value.clamp(0.0, 1.0),
      lineHeight: height,
      padding: EdgeInsets.zero,
      barRadius: Radius.circular(height),
      progressColor: c,
      backgroundColor: c.withValues(alpha: 0.14),
      animation: true,
      animateFromLastPercent: true,
      animationDuration: 500,
      curve: Curves.easeOutCubic,
    );
  }
}
