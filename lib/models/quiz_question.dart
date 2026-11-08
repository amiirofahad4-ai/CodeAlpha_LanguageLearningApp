import '../core/constants.dart';

enum QuizType {
  multipleChoice('Multiple choice'),
  listenAndChoose('Listen & choose'),
  fillInBlank('Fill in the blank'),
  matchPairs('Match pairs');

  const QuizType(this.label);
  final String label;
}

/// A left/right pair for [QuizType.matchPairs].
class MatchPair {
  const MatchPair(this.left, this.right);
  final String left;
  final String right;

  factory MatchPair.fromJson(Map<String, dynamic> json) =>
      MatchPair(json['left'] as String, json['right'] as String);

  Map<String, dynamic> toJson() => {'left': left, 'right': right};
}

/// A single quiz question. Which fields are used depends on [type].
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.languageCode,
    this.options = const [],
    this.correctIndex = 0,
    this.audioText,
    this.sentence,
    this.hint,
    this.pairs = const [],
  });

  final String id;
  final QuizType type;
  final String prompt;

  /// Language of the spoken audio (for TTS).
  final String languageCode;

  final List<String> options;
  final int correctIndex;

  /// Text spoken for [QuizType.listenAndChoose].
  final String? audioText;

  /// Sentence with `_____` for [QuizType.fillInBlank].
  final String? sentence;

  /// Optional helper text (e.g. the Somali translation).
  final String? hint;

  final List<MatchPair> pairs;

  /// Human readable correct answer, used in feedback and review.
  String get correctAnswer => type == QuizType.matchPairs
      ? pairs.map((p) => '${p.left} = ${p.right}').join('\n')
      : options[correctIndex];

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as String,
    type: QuizType.values.byName(json['type'] as String),
    prompt: json['prompt'] as String,
    languageCode: json['languageCode'] as String,
    options: List<String>.from(json['options'] as List? ?? const []),
    correctIndex: json['correctIndex'] as int? ?? 0,
    audioText: json['audioText'] as String?,
    sentence: json['sentence'] as String?,
    hint: json['hint'] as String?,
    pairs: (json['pairs'] as List? ?? const [])
        .map((p) => MatchPair.fromJson(p as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'prompt': prompt,
    'languageCode': languageCode,
    'options': options,
    'correctIndex': correctIndex,
    'audioText': audioText,
    'sentence': sentence,
    'hint': hint,
    'pairs': pairs.map((p) => p.toJson()).toList(),
  };
}

/// What the user answered for one question.
class QuizAnswer {
  const QuizAnswer({
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
  });

  final QuizQuestion question;

  /// `null` when the question was never answered (out of hearts).
  final String? userAnswer;
  final bool isCorrect;
}

/// Outcome of a finished quiz.
class QuizResult {
  const QuizResult({
    required this.answers,
    required this.totalQuestions,
    this.outOfHearts = false,
  });

  final List<QuizAnswer> answers;
  final int totalQuestions;
  final bool outOfHearts;

  int get correctCount => answers.where((a) => a.isCorrect).length;

  /// Unanswered questions count as wrong.
  int get wrongCount => totalQuestions - correctCount;

  int get scorePercent =>
      totalQuestions == 0 ? 0 : (correctCount / totalQuestions * 100).round();

  bool get passed => scorePercent >= AppConstants.passScore;

  int get xpEarned =>
      correctCount * AppConstants.xpPerCorrectAnswer +
      (passed ? AppConstants.xpQuizPassBonus : 0);
}
