/// Route names and paths used with go_router.
///
/// Navigate by name, e.g. `context.pushNamed(AppRoutes.wordDetail,
/// pathParameters: {'wordId': id})`.
abstract final class AppRoutes {
  // Names
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const login = 'login';
  static const register = 'register';
  static const forgotPassword = 'forgotPassword';
  static const chooseLanguage = 'chooseLanguage';
  static const chooseLevel = 'chooseLevel';
  static const home = 'home';
  static const learn = 'learn';
  static const quiz = 'quiz';
  static const progress = 'progress';
  static const profile = 'profile';
  static const wordList = 'wordList';
  static const wordDetail = 'wordDetail';
  static const flashcards = 'flashcards';
  static const grammarDetail = 'grammarDetail';
  static const dailyLesson = 'dailyLesson';
  static const quizSession = 'quizSession';
  static const quizResult = 'quizResult';
  static const quizReview = 'quizReview';

  // Paths
  static const splashPath = '/';
  static const onboardingPath = '/onboarding';
  static const loginPath = '/login';
  static const registerPath = '/register';
  static const forgotPasswordPath = '/forgot-password';
  static const chooseLanguagePath = '/choose-language';
  static const chooseLevelPath = '/choose-level';
  static const homePath = '/home';
  static const learnPath = '/learn';
  static const quizPath = '/quiz';
  static const progressPath = '/progress';
  static const profilePath = '/profile';
  static const wordListPath = '/topic/:topicId';
  static const wordDetailPath = '/word/:wordId';
  static const flashcardsPath = '/flashcards/:topicId';
  static const grammarDetailPath = '/grammar/:lessonId';
  static const dailyLessonPath = '/daily-lesson';
  static const quizSessionPath = '/quiz-session';
  static const quizResultPath = '/quiz-result';
  static const quizReviewPath = '/quiz-review';

  /// Paths reachable without being signed in.
  static const publicPaths = {
    splashPath,
    onboardingPath,
    loginPath,
    registerPath,
    forgotPasswordPath,
  };
}
