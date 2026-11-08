import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/utils/context_ext.dart';

/// Logo, title and subtitle at the top of auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.translate_rounded, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Red banner for errors returned by the auth repository.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message!,
                      style: context.text.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// "Continue with Google" outlined button.
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.colors.onSurface,
          backgroundColor: context.colors.surface,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'G',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF4285F4),
              ),
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Continue with Google',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "—— or ——" divider.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'or',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

/// "Don't have an account? Register" style footer.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(question, style: context.text.bodyMedium),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}
