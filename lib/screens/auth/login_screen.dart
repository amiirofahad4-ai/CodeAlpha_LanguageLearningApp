import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_center.dart';
import 'auth_widgets.dart';

/// Email/password login. On success the router redirect takes the user
/// to the language picker or home.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<AuthProvider>().signIn(
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
                      title: 'Welcome back 👋',
                      subtitle: 'Log in to continue your learning streak.',
                    ),
                    const SizedBox(height: 32),
                    AuthErrorBanner(message: _error),
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
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      controller: _password,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: Validators.password,
                      onSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.pushNamed(AppRoutes.forgotPassword),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: 'Log in',
                      isLoading: busy,
                      onPressed: _submit,
                    ),
                    const OrDivider(),
                    GoogleButton(onPressed: busy ? null : _google),
                    const SizedBox(height: 16),
                    AuthSwitchPrompt(
                      question: "Don't have an account?",
                      action: 'Register',
                      onTap: () => context.goNamed(AppRoutes.register),
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
