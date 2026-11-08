import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_center.dart';
import 'auth_widgets.dart';

/// Create an account with name, email and password.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<AuthProvider>().register(
      _name.text.trim(),
      _email.text.trim(),
      _password.text,
    );
    if (mounted) setState(() => _error = error);
  }

  Future<void> _google() async {
    final error = await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) setState(() => _error = error);
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().isBusy;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 480,
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const AuthHeader(
                      title: 'Create your account',
                      subtitle: 'Start learning a new language today.',
                    ),
                    const SizedBox(height: 32),
                    AuthErrorBanner(message: _error),
                    AppTextField(
                      label: 'Full name',
                      hint: 'e.g. Hodan Ali',
                      icon: Icons.person_outline_rounded,
                      controller: _name,
                      autofillHints: const [AutofillHints.name],
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      icon: Icons.mail_outline_rounded,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      hint: 'At least 6 characters',
                      icon: Icons.lock_outline_rounded,
                      controller: _password,
                      isPassword: true,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Confirm password',
                      hint: 'Repeat your password',
                      icon: Icons.lock_outline_rounded,
                      controller: _confirm,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.confirmPassword(
                        () => _password.text,
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Create account',
                      isLoading: busy,
                      onPressed: _submit,
                    ),
                    const OrDivider(),
                    GoogleButton(onPressed: busy ? null : _google),
                    const SizedBox(height: 16),
                    Text(
                      'By continuing you agree to our Terms and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    AuthSwitchPrompt(
                      question: 'Already have an account?',
                      action: 'Log in',
                      onTap: () => context.goNamed(AppRoutes.login),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
