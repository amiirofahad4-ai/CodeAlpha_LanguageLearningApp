import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/utils/context_ext.dart';

/// Rounded card with a soft shadow (light mode) or subtle border (dark).
/// The base container for almost every card in the app.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.gradient,
    this.borderColor,
    this.radius = AppConstants.radius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final dark = context.isDark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? context.colors.surface) : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: Border.all(
          color:
              borderColor ??
              (dark && gradient == null
                  ? context.colors.outline
                  : Colors.transparent),
          width: borderColor != null ? 2 : 1,
        ),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
