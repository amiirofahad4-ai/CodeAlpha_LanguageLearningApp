import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'core/constants.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/content_repository.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/firestore_progress_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/tts_service.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();

  // ---------------------------------------------------------------------
  // Data layer.
  // * Login and progress: Firebase (progress is also kept on the phone).
  // * Lessons, words, quizzes: bundled in the app (works offline).
  // * Settings: on the phone.
  // ---------------------------------------------------------------------
  final AuthRepository authRepository = FirebaseAuthRepository();
  final ContentRepository contentRepository = MockContentRepository();
  final ProgressRepository progressRepository = FirestoreProgressRepository(
    local: LocalProgressRepository(prefs),
  );
  final SettingsRepository settingsRepository = LocalSettingsRepository(prefs);

  final auth = AuthProvider(authRepository);
  final settings = SettingsProvider(settingsRepository);
  await Future.wait([auth.init(), settings.load()]);

  runApp(
    LinguaLearnApp(
      auth: auth,
      settings: settings,
      contentRepository: contentRepository,
      progressRepository: progressRepository,
    ),
  );
}

class LinguaLearnApp extends StatefulWidget {
  const LinguaLearnApp({
    super.key,
    required this.auth,
    required this.settings,
    required this.contentRepository,
    required this.progressRepository,
  });

  final AuthProvider auth;
  final SettingsProvider settings;
  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;

  @override
  State<LinguaLearnApp> createState() => _LinguaLearnAppState();
}

class _LinguaLearnAppState extends State<LinguaLearnApp> {
  // Created once so navigation state survives rebuilds (e.g. theme change).
  late final GoRouter _router = createRouter(
    auth: widget.auth,
    settings: widget.settings,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ContentRepository>.value(value: widget.contentRepository),
        Provider<TtsService>(
          create: (_) => TtsService(),
          dispose: (_, tts) => tts.stop(),
        ),
        ChangeNotifierProvider.value(value: widget.auth),
        ChangeNotifierProvider.value(value: widget.settings),
        // Progress follows the signed-in user.
        ChangeNotifierProxyProvider<AuthProvider, ProgressProvider>(
          create: (_) => ProgressProvider(widget.progressRepository),
          update: (_, auth, progress) => progress!..setUser(auth.user?.id),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          routerConfig: _router,
        ),
      ),
    );
  }
}
