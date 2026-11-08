import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../core/utils/date_utils.dart';
import '../data/repositories/progress_repository.dart';
import '../models/progress.dart';
import '../models/quiz_question.dart';
import '../models/topic.dart';
import '../models/word.dart';

/// Tracks XP, streak, learned words, quizzes and activity for the
/// signed-in user. Every change is saved through [ProgressRepository].
class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._repository);

  final ProgressRepository _repository;

  String? _userId;
  UserProgress _progress = const UserProgress();
  bool _isLoading = false;

  UserProgress get progress => _progress;
  bool get isLoading => _isLoading;

  int get xp => _progress.xp;
  int get quizzesTaken => _progress.quizzesTaken;
  double get averageScore => _progress.averageScore;
  List<String> get recentTopicIds => _progress.recentTopicIds;

  /// Streak is 0 if the user missed yesterday and has not practised today.
  int get streak {
    final last = _progress.lastActiveDay;
    if (last == DateUtilsX.todayKey() || last == DateUtilsX.yesterdayKey()) {
      return _progress.streak;
    }
    return 0;
  }

  int get todayXp => _progress.dailyXp[DateUtilsX.todayKey()] ?? 0;

  bool get dailyLessonDoneToday =>
      _progress.lastDailyLessonDay == DateUtilsX.todayKey();

  /// XP for each of the last 7 days (oldest first).
  List<(DateTime, int)> get weeklyActivity => [
    for (final day in DateUtilsX.lastSevenDays())
      (day, _progress.dailyXp[DateUtilsX.dayKey(day)] ?? 0),
  ];

  bool isLearned(String wordId) => _progress.learnedWordIds.contains(wordId);

  bool isGrammarCompleted(String lessonId) =>
      _progress.completedGrammarIds.contains(lessonId);

  /// Words learned in a language (ids are prefixed with the language code).
  int learnedCount(String languageCode) => _progress.learnedWordIds
      .where((id) => id.startsWith('${languageCode}_'))
      .length;

  int grammarCompletedCount(String languageCode) => _progress
      .completedGrammarIds
      .where((id) => id.startsWith('${languageCode}_'))
      .length;

  /// 0.0 – 1.0 completion for a topic.
  double topicProgress(Topic topic) {
    if (topic.wordCount == 0) return 0;
    final learned = _progress.learnedWordIds
        .where((id) => id.startsWith('${topic.id}_'))
        .length;
    return (learned / topic.wordCount).clamp(0.0, 1.0);
  }

  /// Called by the proxy provider whenever the signed-in user changes.
  Future<void> setUser(String? userId) async {
    if (userId == _userId) return;
    _userId = userId;
    if (userId == null) {
      _progress = const UserProgress();
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _progress = await _repository.load(userId);
    } catch (e) {
      debugPrint('Could not load progress: $e');
      _progress = const UserProgress();
    }
    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------- actions

  Future<void> toggleLearned(Word word) =>
      isLearned(word.id) ? unmarkLearned(word) : markLearned([word]);

  /// Marks words as learned and awards XP for newly learned ones.
  Future<void> markLearned(List<Word> words) async {
    final newIds = words
        .map((w) => w.id)
        .where((id) => !isLearned(id))
        .toList();
    if (newIds.isEmpty) return;
    _progress = _progress.copyWith(
      learnedWordIds: {..._progress.learnedWordIds, ...newIds},
    );
    await addXp(newIds.length * AppConstants.xpPerLearnedWord);
  }

  Future<void> unmarkLearned(Word word) async {
    _progress = _progress.copyWith(
      learnedWordIds: {..._progress.learnedWordIds}..remove(word.id),
    );
    await _save();
  }

  /// Remembers a topic for the "Continue learning" list.
  Future<void> visitTopic(String topicId) async {
    final recent = [
      topicId,
      ..._progress.recentTopicIds.where((t) => t != topicId),
    ];
    _progress = _progress.copyWith(recentTopicIds: recent.take(6).toList());
    await _save();
  }

  Future<void> recordQuiz(QuizResult result) async {
    _progress = _progress.copyWith(
      quizzesTaken: _progress.quizzesTaken + 1,
      totalQuizScore: _progress.totalQuizScore + result.scorePercent,
    );
    await addXp(result.xpEarned);
  }

  /// Returns `true` the first time a lesson is completed.
  Future<bool> completeGrammar(String lessonId) async {
    if (isGrammarCompleted(lessonId)) return false;
    _progress = _progress.copyWith(
      completedGrammarIds: {..._progress.completedGrammarIds, lessonId},
    );
    await addXp(AppConstants.xpGrammarLesson);
    return true;
  }

  Future<void> completeDailyLesson({required int bonusXp}) async {
    _progress = _progress.copyWith(lastDailyLessonDay: DateUtilsX.todayKey());
    await addXp(bonusXp);
  }

  /// Adds XP for today and updates the streak.
  Future<void> addXp(int amount) async {
    final today = DateUtilsX.todayKey();
    final last = _progress.lastActiveDay;
    final int streak;
    if (last == today) {
      streak = _progress.streak; // already counted today
    } else if (last == DateUtilsX.yesterdayKey()) {
      streak = _progress.streak + 1; // kept the streak going
    } else {
      streak = 1; // new streak
    }
    _progress = _progress.copyWith(
      xp: _progress.xp + amount,
      streak: streak,
      lastActiveDay: today,
      dailyXp: {..._progress.dailyXp, today: todayXp + amount},
    );
    await _save();
  }

  Future<void> _save() async {
    notifyListeners();
    final id = _userId;
    if (id == null) return;
    try {
      await _repository.save(id, _progress);
    } catch (e) {
      debugPrint('Could not save progress: $e');
    }
  }
}
