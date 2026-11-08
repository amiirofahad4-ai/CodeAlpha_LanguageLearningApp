import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';

/// Logo + app name, then routes to onboarding, login, language picker or
/// home depending on the saved state.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppConstants.splashDuration, _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    final auth = context.read<AuthProvider>();
    final String route;
    if (!settings.onboardingSeen) {
      route = AppRoutes.onboarding;
    } else if (!auth.isLoggedIn) {
      route = AppRoutes.login;
    } else if (!settings.hasLanguage) {
      route = AppRoutes.chooseLanguage;
    } else {
      route = AppRoutes.home;
    }
    context.goNamed(route);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    Text(
                      AppConstants.appName,
                      style: context.text.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ku baro luqadaha af Soomaali',
                      style: context.text.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
