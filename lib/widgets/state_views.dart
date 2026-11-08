import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/utils/context_ext.dart';
import 'primary_button.dart';

/// Centered spinner with an optional message.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!, style: context.text.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

/// Friendly error with a retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Please check your connection and try again.',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      icon: Icons.cloud_off_rounded,
      iconColor: AppColors.error,
      title: title,
      message: message,
      action: onRetry == null
          ? null
          : PrimaryButton(
              label: 'Try again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
              expand: false,
            ),
    );
  }
}

/// Shown when a list has nothing in it.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_rounded,
    this.action,
    this.compact = false,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  /// Smaller version for use inside cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      icon: icon,
      iconColor: context.colors.primary,
      title: title,
      message: message,
      action: action,
      compact: compact,
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.message,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 56.0 : 88.0;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? 12 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: size * 0.5, color: iconColor),
            ),
            SizedBox(height: compact ? 12 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
                  (compact ? context.text.titleSmall : context.text.titleLarge)
                      ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
