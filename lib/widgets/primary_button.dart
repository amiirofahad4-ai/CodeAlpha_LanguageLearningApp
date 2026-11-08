import 'package:flutter/material.dart';

import '../core/app_colors.dart';

enum ButtonVariant { primary, success, danger, outlined, light }

/// Large, full-width button used for main actions.
///
/// Shows a spinner while [isLoading] and is disabled when [onPressed] is
/// `null`.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !isLoading;

    final (Color? bg, Color fg) = switch (variant) {
      ButtonVariant.primary => (scheme.primary, Colors.white),
      ButtonVariant.success => (AppColors.secondary, Colors.white),
      ButtonVariant.danger => (AppColors.error, Colors.white),
      ButtonVariant.light => (Colors.white, AppColors.primary),
      ButtonVariant.outlined => (null, scheme.onSurface),
    };

    final content = isLoading
        ? SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final Widget button = variant == ButtonVariant.outlined
        ? OutlinedButton(
            onPressed: enabled ? onPressed : null,
            style: OutlinedButton.styleFrom(foregroundColor: fg),
            child: content,
          )
        : FilledButton(
            onPressed: enabled ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              disabledBackgroundColor: isLoading ? bg : null,
            ),
            child: content,
          );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
