import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../core/utils/context_ext.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_center.dart';

class _Slide {
  const _Slide(this.icon, this.color, this.title, this.body, this.chip);
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String chip;
}

const _slides = [
  _Slide(
    Icons.menu_book_rounded,
    AppColors.primary,
    'Learn vocabulary',
    'Discover words and phrases with Somali translations, examples and '
        'real pronunciation.',
    'Mother = Hooyo',
  ),
  _Slide(
    Icons.style_rounded,
    AppColors.secondary,
    'Practice with flashcards',
    'Flip, swipe and remember. Short daily sessions build a memory that '
        'lasts.',
    'I know ✓',
  ),
  _Slide(
    Icons.emoji_events_rounded,
    AppColors.streak,
    'Test with quizzes',
    'Fun quizzes measure your progress, earn XP and keep your streak '
        'alive.',
    '🔥 7 day streak',
  ),
];

/// Three intro slides with Skip / Next / Get Started.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  Future<void> _finish() async {
    await context.read<SettingsProvider>().completeOnboarding();
    if (mounted) context.goNamed(AppRoutes.login);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  opacity: _isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _isLast ? null : _finish,
                    child: const Text('Skip'),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                ),
              ),
              // Page dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? _slides[_page].color
                            : context.colors.outline,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                child: PrimaryButton(
                  label: _isLast ? 'Get Started' : 'Next',
                  icon: _isLast ? Icons.rocket_launch_rounded : null,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Smaller illustration on short screens.
        final size = (constraints.maxHeight * 0.48).clamp(160.0, 300.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Illustration(slide: slide, size: size),
                const SizedBox(height: 36),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: context.text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.body,
                  textAlign: TextAlign.center,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Concentric circles, a big icon and a floating chip.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.slide, required this.size});
  final _Slide slide;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _circle(size, 0.08),
            _circle(size * 0.75, 0.12),
            _circle(size * 0.5, 1, gradient: true),
            Icon(slide.icon, size: size * 0.24, color: Colors.white),
            Positioned(
              right: 0,
              bottom: size * 0.12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  slide.chip,
                  style: context.text.labelLarge?.copyWith(
                    color: slide.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double d, double alpha, {bool gradient = false}) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: gradient ? null : slide.color.withValues(alpha: alpha),
      gradient: gradient
          ? LinearGradient(
              colors: [slide.color, slide.color.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
    ),
  );
}
