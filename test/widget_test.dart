import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingualearn/data/mock_data.dart';
import 'package:lingualearn/data/quiz_generator.dart';
import 'package:lingualearn/data/repositories/content_repository.dart';
import 'package:lingualearn/data/repositories/progress_repository.dart';
import 'package:lingualearn/models/quiz_question.dart';
import 'package:lingualearn/providers/progress_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Mock data', () {
    test('has at least 3 languages with content', () {
      expect(MockData.contentLanguages.length, greaterThanOrEqualTo(3));
    });

    test('every content language has 6 topics with 10 words each', () {
      for (final lang in MockData.contentLanguages) {
        final topics = MockData.topics.where((t) => t.languageCode == lang);
        expect(topics.length, 6, reason: lang);
        for (final t in topics) {
          final words = MockData.words.where((w) => w.topicId == t.id);
          expect(words.length, 10, reason: t.id);
        }
      }
    });

    test('has at least 5 grammar lessons', () {
      expect(MockData.grammarLessons.length, greaterThanOrEqualTo(5));
    });

    test('word ids are unique', () {
      final ids = MockData.words.map((w) => w.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('QuizGenerator', () {
    final pool = MockData.words.where((w) => w.languageCode == 'en').toList();
    final generator = QuizGenerator(Random(1));

    test('creates 20 questions covering all 4 types', () {
      final quiz = generator.generate(targets: pool, pool: pool, count: 20);
      expect(quiz.length, 20);
      expect(quiz.map((q) => q.type).toSet(), QuizType.values.toSet());
    });

    test('options contain the correct answer exactly once', () {
      final quiz = generator.generate(targets: pool, pool: pool, count: 40);
      for (final q in quiz.where((q) => q.type != QuizType.matchPairs)) {
        expect(q.options.toSet().length, q.options.length, reason: q.prompt);
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
      }
    });

    test('match pairs have 4 distinct pairs', () {
      final quiz = generator.generate(targets: pool, pool: pool, count: 20);
      for (final q in quiz.where((q) => q.type == QuizType.matchPairs)) {
        expect(q.pairs.length, 4);
        expect(q.pairs.map((p) => p.right).toSet().length, 4);
      }
    });

    test('blankSentence replaces whole words only', () {
      final mother = pool.firstWhere((w) => w.text == 'Mother');
      expect(QuizGenerator.blankSentence(mother), 'My _____ is a teacher.');
    });
  });

  group('MockContentRepository', () {
    final repo = MockContentRepository(delay: Duration.zero);

    test('returns a 20-question quiz', () async {
      final quiz = await repo.getQuiz(languageCode: 'ar');
      expect(quiz.length, 20);
    });

    test('daily lesson skips learned words', () async {
      final all = await repo.getAllWords('tr');
      final learned = all.take(3).map((w) => w.id).toSet();
      final daily = await repo.getDailyLessonWords('tr', learnedIds: learned);
      expect(daily.length, 5);
      expect(daily.any((w) => learned.contains(w.id)), isFalse);
    });

    test('unknown ids return null instead of throwing', () async {
      expect(await repo.getWord('nope'), isNull);
      expect(await repo.getTopic('nope'), isNull);
    });
  });

  group('ProgressProvider', () {
    late ProgressProvider progress;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      progress = ProgressProvider(LocalProgressRepository(prefs));
      await progress.setUser('test-user');
    });

    test(
      'learning words adds XP, starts a streak and updates topic %',
      () async {
        final topic = MockData.topics.first;
        final words = MockData.words
            .where((w) => w.topicId == topic.id)
            .take(5)
            .toList();
        await progress.markLearned(words);

        expect(progress.xp, 25);
        expect(progress.todayXp, 25);
        expect(progress.streak, 1);
        expect(progress.topicProgress(topic), 0.5);
      },
    );

    test('quiz results update the average score', () async {
      final q = QuizGenerator(Random(2)).generate(
        targets: MockData.words.take(10).toList(),
        pool: MockData.words,
        count: 10,
      );
      final answers = [
        for (var i = 0; i < 10; i++)
          QuizAnswer(question: q[i], userAnswer: 'x', isCorrect: i < 8),
      ];
      final result = QuizResult(answers: answers, totalQuestions: 10);
      await progress.recordQuiz(result);

      expect(result.scorePercent, 80);
      expect(result.passed, isTrue);
      expect(progress.quizzesTaken, 1);
      expect(progress.averageScore, 80);
    });
  });
}
