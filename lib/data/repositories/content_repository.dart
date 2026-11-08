import '../../core/constants.dart';
import '../../models/grammar_lesson.dart';
import '../../models/language.dart';
import '../../models/quiz_question.dart';
import '../../models/topic.dart';
import '../../models/word.dart';
import '../mock_data.dart';
import '../quiz_generator.dart';

/// Read access to learning content.
///
/// To use Firebase, create `FirestoreContentRepository implements
/// ContentRepository` and register it in `main.dart` instead of
/// [MockContentRepository]. No screen code needs to change.
abstract interface class ContentRepository {
  Future<List<Language>> getLanguages();
  Future<Language?> getLanguage(String code);

  Future<List<Topic>> getTopics(String languageCode);
  Future<Topic?> getTopic(String topicId);

  Future<List<Word>> getWords(String topicId);
  Future<List<Word>> getAllWords(String languageCode);
  Future<Word?> getWord(String wordId);

  Future<List<GrammarLesson>> getGrammarLessons(String languageCode);
  Future<GrammarLesson?> getGrammarLesson(String lessonId);

  /// A quiz for a language, optionally limited to one topic.
  Future<List<QuizQuestion>> getQuiz({
    required String languageCode,
    String? topicId,
    int count = AppConstants.quizLength,
  });

  /// A short quiz about specific words (used by the daily lesson).
  Future<List<QuizQuestion>> getQuizForWords(List<Word> words, {int? count});

  /// Words for today's lesson, preferring ones not learned yet.
  Future<List<Word>> getDailyLessonWords(
    String languageCode, {
    required Set<String> learnedIds,
    int count = AppConstants.dailyLessonWordCount,
  });
}

/// In-memory implementation backed by [MockData].
class MockContentRepository implements ContentRepository {
  MockContentRepository({
    this.delay = AppConstants.mockNetworkDelay,
    QuizGenerator? quizGenerator,
  }) : _quiz = quizGenerator ?? QuizGenerator();

  /// Fake network latency so loading states are visible.
  final Duration delay;
  final QuizGenerator _quiz;

  Future<T> _respond<T>(T Function() compute) async {
    await Future<void>.delayed(delay);
    return compute();
  }

  @override
  Future<List<Language>> getLanguages() => _respond(() => MockData.languages);

  @override
  Future<Language?> getLanguage(String code) => _respond(
    () => MockData.languages.where((l) => l.code == code).firstOrNull,
  );

  @override
  Future<List<Topic>> getTopics(String languageCode) => _respond(
    () => MockData.topics.where((t) => t.languageCode == languageCode).toList(),
  );

  @override
  Future<Topic?> getTopic(String topicId) =>
      _respond(() => MockData.topics.where((t) => t.id == topicId).firstOrNull);

  @override
  Future<List<Word>> getWords(String topicId) => _respond(
    () => MockData.words.where((w) => w.topicId == topicId).toList(),
  );

  @override
  Future<List<Word>> getAllWords(String languageCode) => _respond(
    () => MockData.words.where((w) => w.languageCode == languageCode).toList(),
  );

  @override
  Future<Word?> getWord(String wordId) =>
      _respond(() => MockData.words.where((w) => w.id == wordId).firstOrNull);

  @override
  Future<List<GrammarLesson>> getGrammarLessons(String languageCode) =>
      _respond(
        () =>
            MockData.grammarLessons
                .where((g) => g.languageCode == languageCode)
                .toList()
              ..sort((a, b) => a.order.compareTo(b.order)),
      );

  @override
  Future<GrammarLesson?> getGrammarLesson(String lessonId) => _respond(
    () => MockData.grammarLessons.where((g) => g.id == lessonId).firstOrNull,
  );

  @override
  Future<List<QuizQuestion>> getQuiz({
    required String languageCode,
    String? topicId,
    int count = AppConstants.quizLength,
  }) => _respond(() {
    final pool = MockData.words
        .where((w) => w.languageCode == languageCode)
        .toList();
    final targets = topicId == null
        ? pool
        : pool.where((w) => w.topicId == topicId).toList();
    return _quiz.generate(targets: targets, pool: pool, count: count);
  });

  @override
  Future<List<QuizQuestion>> getQuizForWords(List<Word> words, {int? count}) =>
      _respond(() {
        if (words.isEmpty) return const <QuizQuestion>[];
        final lang = words.first.languageCode;
        final pool = MockData.words
            .where((w) => w.languageCode == lang)
            .toList();
        return _quiz.generate(
          targets: words,
          pool: pool,
          count: count ?? words.length,
        );
      });

  @override
  Future<List<Word>> getDailyLessonWords(
    String languageCode, {
    required Set<String> learnedIds,
    int count = AppConstants.dailyLessonWordCount,
  }) => _respond(
    () => MockData.words
        .where(
          (w) => w.languageCode == languageCode && !learnedIds.contains(w.id),
        )
        .take(count)
        .toList(),
  );
}
