import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingualearn/data/repositories/auth_repository.dart';
import 'package:lingualearn/data/repositories/content_repository.dart';
import 'package:lingualearn/data/repositories/progress_repository.dart';
import 'package:lingualearn/data/repositories/settings_repository.dart';
import 'package:lingualearn/main.dart';
import 'package:lingualearn/providers/auth_provider.dart';
import 'package:lingualearn/providers/settings_provider.dart';
import 'package:lingualearn/widgets/quiz_option.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Renders every screen on a small phone to catch layout/runtime errors.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  Future<void> boot(
    WidgetTester tester,
    Map<String, Object> prefsValues, {
    Size size = const Size(360, 690),
    bool dark = false,
  }) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefsValues);
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthProvider(MockAuthRepository(prefs));
    final settings = SettingsProvider(LocalSettingsRepository(prefs));
    await tester.runAsync(() => Future.wait([auth.init(), settings.load()]));
    if (dark) {
      await tester.runAsync(() => settings.setThemeMode(ThemeMode.dark));
    }
    await tester.pumpWidget(
      LinguaLearnApp(
        auth: auth,
        settings: settings,
        contentRepository: MockContentRepository(delay: Duration.zero),
        progressRepository: LocalProgressRepository(prefs),
      ),
    );
  }

  const loggedIn = {
    'auth.currentUser': '{"id":"u","name":"Hodan Ali","email":"hodan@x.com"}',
    'settings':
        '{"onboardingSeen":true,"languageCode":"en","level":"beginner"}',
  };

  final routes = [
    '/home',
    '/learn',
    '/learn?tab=grammar',
    '/quiz',
    '/progress',
    '/profile',
    '/topic/en_family',
    '/word/en_family_mother',
    '/flashcards/en_food',
    '/grammar/en_g1',
    '/daily-lesson',
    '/quiz-session',
    '/quiz-result',
    '/quiz-review',
    '/choose-language',
    '/choose-level?lang=ar',
    '/topic/missing',
    '/word/missing',
    '/nowhere',
  ];

  for (final dark in [false, true]) {
    testWidgets('all screens render (dark: $dark)', (tester) async {
      await boot(tester, loggedIn, dark: dark);
      await tester.pump(const Duration(seconds: 3)); // splash
      await tester.pumpAndSettle();
      final ctx = tester.element(find.byType(Navigator).first);
      final router = GoRouter.of(ctx);
      for (final r in routes) {
        router.go(r);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(seconds: 2));
        final e = tester.takeException();
        expect(e, isNull, reason: 'route $r threw $e');
      }
    });
  }

  testWidgets('logged-out flow: onboarding, login, register, forgot', (
    tester,
  ) async {
    await boot(tester, {});
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Learn vocabulary'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back 👋'), findsOneWidget);
    // Validation errors
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);
    final router = GoRouter.of(tester.element(find.byType(Navigator).first));
    for (final r in ['/register', '/forgot-password', '/home']) {
      router.go(r);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: r);
    }
    // Protected route redirects to login
    expect(find.text('Welcome back 👋'), findsOneWidget);
  });

  testWidgets('quiz can be answered to the result screen', (tester) async {
    await boot(tester, loggedIn);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    GoRouter.of(
      tester.element(find.byType(Navigator).first),
    ).go('/quiz-session?topicId=en_colors');
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    for (var i = 0; i < 30; i++) {
      if (find.text('Back to Home').evaluate().isNotEmpty) break;
      final option = find.text('A');
      if (option.evaluate().isNotEmpty) {
        await tester.tap(option.first);
        await tester.pump();
        await tester.tap(find.text('Check'));
        await tester.pump(const Duration(seconds: 1));
      } else {
        // Match pairs: try every left/right combination.
        final tiles = find.byType(QuizOption);
        final n = tiles.evaluate().length ~/ 2;
        outer:
        for (var l = 0; l < n; l++) {
          for (var r = n; r < n * 2; r++) {
            if (find.text('Continue').evaluate().isNotEmpty) break outer;
            await tester.tap(tiles.at(l), warnIfMissed: false);
            await tester.pump();
            await tester.tap(tiles.at(r), warnIfMissed: false);
            await tester.pump(const Duration(milliseconds: 700));
          }
        }
        await tester.pump(const Duration(seconds: 1));
      }
      if (find.text('Continue').evaluate().isNotEmpty) {
        await tester.tap(find.text('Continue'));
        await tester.pump(const Duration(seconds: 1));
      }
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Back to Home'), findsOneWidget);
  });
}
