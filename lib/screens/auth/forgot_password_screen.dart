import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_center.dart';
import 'auth_widgets.dart';

/// Sends a password reset email, then shows a confirmation.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<AuthProvider>().sendPasswordReset(
      _email.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _error = error;
      _sent = error == null;
    });
  }

  void _back() =>
      context.canPop() ? context.pop() : context.goNamed(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().isBusy;

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: _back)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 480,
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _sent ? _buildSent() : _buildForm(busy),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool busy) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: 'Forgot password?',
            subtitle: "Enter your email and we'll send you a reset link.",
          ),
          const SizedBox(height: 32),
          AuthErrorBanner(message: _error),
          AppTextField(
            label: 'Email',
            hint: 'you@example.com',
            icon: Icons.mail_outline_rounded,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Send reset link',
            isLoading: busy,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSent() {
    return Column(
      key: const ValueKey('sent'),
      children: [
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 56,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Check your email',
          style: context.text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a password reset link to\n${_email.text.trim()}',
          textAlign: TextAlign.center,
          style: context.text.bodyLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(label: 'Back to login', onPressed: _back),
      ],
    );
  }
}
