/// Everything we track about a learner's progress.
///
/// Immutable; [ProgressProvider] creates new copies on every change.
class UserProgress {
  const UserProgress({
    this.xp = 0,
    this.streak = 0,
    this.lastActiveDay,
    this.learnedWordIds = const {},
    this.completedGrammarIds = const {},
    this.quizzesTaken = 0,
    this.totalQuizScore = 0,
    this.dailyXp = const {},
    this.recentTopicIds = const [],
    this.lastDailyLessonDay,
  });

  final int xp;
  final int streak;

  /// `yyyy-MM-dd` of the last day with activity.
  final String? lastActiveDay;
  final Set<String> learnedWordIds;
  final Set<String> completedGrammarIds;
  final int quizzesTaken;

  /// Sum of all quiz scores (%), used for the average.
  final int totalQuizScore;

  /// XP earned per day, keyed by `yyyy-MM-dd`.
  final Map<String, int> dailyXp;

  /// Most recent first.
  final List<String> recentTopicIds;
  final String? lastDailyLessonDay;

  double get averageScore =>
      quizzesTaken == 0 ? 0 : totalQuizScore / quizzesTaken;

  UserProgress copyWith({
    int? xp,
    int? streak,
    String? lastActiveDay,
    Set<String>? learnedWordIds,
    Set<String>? completedGrammarIds,
    int? quizzesTaken,
    int? totalQuizScore,
    Map<String, int>? dailyXp,
    List<String>? recentTopicIds,
    String? lastDailyLessonDay,
  }) {
    return UserProgress(
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      lastActiveDay: lastActiveDay ?? this.lastActiveDay,
      learnedWordIds: learnedWordIds ?? this.learnedWordIds,
      completedGrammarIds: completedGrammarIds ?? this.completedGrammarIds,
      quizzesTaken: quizzesTaken ?? this.quizzesTaken,
      totalQuizScore: totalQuizScore ?? this.totalQuizScore,
      dailyXp: dailyXp ?? this.dailyXp,
      recentTopicIds: recentTopicIds ?? this.recentTopicIds,
      lastDailyLessonDay: lastDailyLessonDay ?? this.lastDailyLessonDay,
    );
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
    xp: json['xp'] as int? ?? 0,
    streak: json['streak'] as int? ?? 0,
    lastActiveDay: json['lastActiveDay'] as String?,
    learnedWordIds: Set<String>.from(
      json['learnedWordIds'] as List? ?? const [],
    ),
    completedGrammarIds: Set<String>.from(
      json['completedGrammarIds'] as List? ?? const [],
    ),
    quizzesTaken: json['quizzesTaken'] as int? ?? 0,
    totalQuizScore: json['totalQuizScore'] as int? ?? 0,
    dailyXp: Map<String, int>.from(json['dailyXp'] as Map? ?? const {}),
    recentTopicIds: List<String>.from(
      json['recentTopicIds'] as List? ?? const [],
    ),
    lastDailyLessonDay: json['lastDailyLessonDay'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'streak': streak,
    'lastActiveDay': lastActiveDay,
    'learnedWordIds': learnedWordIds.toList(),
    'completedGrammarIds': completedGrammarIds.toList(),
    'quizzesTaken': quizzesTaken,
    'totalQuizScore': totalQuizScore,
    'dailyXp': dailyXp,
    'recentTopicIds': recentTopicIds,
    'lastDailyLessonDay': lastDailyLessonDay,
  };
}
