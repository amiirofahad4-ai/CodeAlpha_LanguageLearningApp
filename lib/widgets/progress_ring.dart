import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../core/utils/context_ext.dart';

/// Animated circular progress with a widget (usually text) in the middle.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.radius = 36,
    this.lineWidth = 8,
    this.color,
    this.trackColor,
    this.center,
  });

  /// 0.0 – 1.0
  final double value;
  final double radius;
  final double lineWidth;
  final Color? color;
  final Color? trackColor;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.primary;
    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      percent: value.clamp(0.0, 1.0),
      animation: true,
      animateFromLastPercent: true,
      animationDuration: 800,
      curve: Curves.easeOutCubic,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: c,
      backgroundColor: trackColor ?? c.withValues(alpha: 0.14),
      center:
          center ??
          Text(
            '${(value.clamp(0.0, 1.0) * 100).round()}%',
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
    );
  }
}
