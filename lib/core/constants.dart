/// App-wide constants: sizes, timings and gamification rules.
abstract final class AppConstants {
  static const appName = 'LinguaLearn';
  static const appVersion = '1.0.0';

  // Layout
  static const radius = 16.0;
  static const pagePadding = 20.0;
  static const maxContentWidth = 640.0;

  // Timings
  static const splashDuration = Duration(seconds: 2);
  static const mockNetworkDelay = Duration(milliseconds: 450);

  // Learning rules
  static const quizLength = 20;
  static const maxHearts = 5;
  static const dailyLessonWordCount = 5;
  static const passScore = 70; // % needed for confetti / bonus XP

  // XP rewards
  static const xpPerLearnedWord = 5;
  static const xpPerCorrectAnswer = 2;
  static const xpQuizPassBonus = 10;
  static const xpDailyLessonBonus = 20;
  static const xpGrammarLesson = 15;
  static const xpPerKnownFlashcard = 1;

  /// Daily goal choices in XP.
  static const dailyGoalOptions = [10, 20, 30, 50];
  static const defaultDailyGoal = 20;
}
