import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/quiz_question.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/daily_lesson/daily_lesson_screen.dart';
import '../screens/flashcards/flashcards_screen.dart';
import '../screens/grammar_detail/grammar_lesson_detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/language/choose_language_screen.dart';
import '../screens/language/choose_level_screen.dart';
import '../screens/learn/learn_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/quiz/quiz_hub_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/quiz_result/quiz_result_screen.dart';
import '../screens/quiz_result/quiz_review_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/word_detail/word_detail_screen.dart';
import '../screens/word_list/word_list_screen.dart';
import '../widgets/primary_button.dart';
import '../widgets/state_views.dart';
import 'app_routes.dart';

/// Builds the app router. Create it once (in `main`) and reuse it.
GoRouter createRouter({
  required AuthProvider auth,
  required SettingsProvider settings,
}) {
  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    // Re-run [redirect] when the user signs in or out.
    refreshListenable: auth,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isPublic = AppRoutes.publicPaths.contains(location);

      if (!auth.isLoggedIn && !isPublic) return AppRoutes.loginPath;

      final onAuthPage =
          location == AppRoutes.loginPath ||
          location == AppRoutes.registerPath ||
          location == AppRoutes.forgotPasswordPath;
      if (auth.isLoggedIn && onAuthPage) {
        return settings.hasLanguage
            ? AppRoutes.homePath
            : AppRoutes.chooseLanguagePath;
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: EmptyView(
        icon: Icons.explore_off_rounded,
        title: 'Page not found',
        message: state.uri.toString(),
        action: PrimaryButton(
          label: 'Go home',
          expand: false,
          onPressed: () => context.go(AppRoutes.homePath),
        ),
      ),
    ),
    routes: [
      _route(
        AppRoutes.splashPath,
        AppRoutes.splash,
        (_) => const SplashScreen(),
      ),
      _route(
        AppRoutes.onboardingPath,
        AppRoutes.onboarding,
        (_) => const OnboardingScreen(),
      ),
      _route(AppRoutes.loginPath, AppRoutes.login, (_) => const LoginScreen()),
      _route(
        AppRoutes.registerPath,
        AppRoutes.register,
        (_) => const RegisterScreen(),
      ),
      _route(
        AppRoutes.forgotPasswordPath,
        AppRoutes.forgotPassword,
        (_) => const ForgotPasswordScreen(),
      ),
      _route(
        AppRoutes.chooseLanguagePath,
        AppRoutes.chooseLanguage,
        (_) => const ChooseLanguageScreen(),
      ),
      _route(
        AppRoutes.chooseLevelPath,
        AppRoutes.chooseLevel,
        (s) => ChooseLevelScreen(languageCode: s.uri.queryParameters['lang']),
      ),

      // Main app with bottom navigation. Each tab keeps its own stack.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          _branch(
            AppRoutes.homePath,
            AppRoutes.home,
            (_) => const HomeScreen(),
          ),
          _branch(
            AppRoutes.learnPath,
            AppRoutes.learn,
            (s) => LearnScreen(initialTab: s.uri.queryParameters['tab']),
          ),
          _branch(
            AppRoutes.quizPath,
            AppRoutes.quiz,
            (_) => const QuizHubScreen(),
          ),
          _branch(
            AppRoutes.progressPath,
            AppRoutes.progress,
            (_) => const ProgressScreen(),
          ),
          _branch(
            AppRoutes.profilePath,
            AppRoutes.profile,
            (_) => const ProfileScreen(),
          ),
        ],
      ),

      // Full-screen pages shown above the bottom navigation.
      _route(
        AppRoutes.wordListPath,
        AppRoutes.wordList,
        (s) => WordListScreen(topicId: s.pathParameters['topicId']!),
      ),
      _route(
        AppRoutes.wordDetailPath,
        AppRoutes.wordDetail,
        (s) => WordDetailScreen(wordId: s.pathParameters['wordId']!),
      ),
      _route(
        AppRoutes.flashcardsPath,
        AppRoutes.flashcards,
        (s) => FlashcardsScreen(topicId: s.pathParameters['topicId']!),
      ),
      _route(
        AppRoutes.grammarDetailPath,
        AppRoutes.grammarDetail,
        (s) =>
            GrammarLessonDetailScreen(lessonId: s.pathParameters['lessonId']!),
      ),
      _route(
        AppRoutes.dailyLessonPath,
        AppRoutes.dailyLesson,
        (_) => const DailyLessonScreen(),
      ),
      _route(
        AppRoutes.quizSessionPath,
        AppRoutes.quizSession,
        (s) => QuizScreen(topicId: s.uri.queryParameters['topicId']),
      ),
      _route(
        AppRoutes.quizResultPath,
        AppRoutes.quizResult,
        (s) => QuizResultScreen(result: s.extra as QuizResult?),
      ),
      _route(
        AppRoutes.quizReviewPath,
        AppRoutes.quizReview,
        (s) => QuizReviewScreen(result: s.extra as QuizResult?),
      ),
    ],
  );
}

/// A top-level route with a fade + slide page transition.
GoRoute _route(
  String path,
  String name,
  Widget Function(GoRouterState state) build,
) {
  return GoRoute(
    path: path,
    name: name,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: build(state),
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

/// One bottom-navigation tab (no transition when switching tabs).
StatefulShellBranch _branch(
  String path,
  String name,
  Widget Function(GoRouterState state) build,
) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        name: name,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: build(state)),
      ),
    ],
  );
}
