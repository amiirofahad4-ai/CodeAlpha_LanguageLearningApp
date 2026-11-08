import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/utils/context_ext.dart';
import '../models/language.dart';

/// Small coloured pill showing a [LanguageLevel].
class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level});

  final LanguageLevel level;

  static Color colorOf(LanguageLevel level) => switch (level) {
    LanguageLevel.beginner => AppColors.secondary,
    LanguageLevel.intermediate => AppColors.warning,
    LanguageLevel.advanced => AppColors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorOf(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level.label,
        style: context.text.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
