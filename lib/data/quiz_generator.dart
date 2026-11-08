import 'dart:math';

import '../models/quiz_question.dart';
import '../models/word.dart';

/// Builds quiz questions from vocabulary so every language and topic gets
/// quizzes automatically. With Firebase you can keep using this, or store
/// hand-written [QuizQuestion]s and return them from the repository instead.
class QuizGenerator {
  QuizGenerator([Random? random]) : _rng = random ?? Random();

  final Random _rng;

  /// The order question types rotate in.
  static const _cycle = [
    QuizType.multipleChoice,
    QuizType.listenAndChoose,
    QuizType.fillInBlank,
    QuizType.multipleChoice,
    QuizType.matchPairs,
  ];

  /// Creates [count] questions about [targets]. Wrong options come from
  /// [pool] (usually every word in the language).
  List<QuizQuestion> generate({
    required List<Word> targets,
    required List<Word> pool,
    int count = 20,
  }) {
    if (targets.isEmpty) return const [];
    final words = [...targets]..shuffle(_rng);
    return [
      for (var i = 0; i < count; i++)
        _build(_cycle[i % _cycle.length], words[i % words.length], pool, i),
    ];
  }

  QuizQuestion _build(QuizType type, Word word, List<Word> pool, int index) {
    final id = 'q${index}_${word.id}';
    switch (type) {
      case QuizType.multipleChoice:
        // Alternate direction: word → Somali, and Somali → word.
        if (index.isEven) {
          final options = _options(word, pool, (w) => w.translation);
          return QuizQuestion(
            id: id,
            type: type,
            languageCode: word.languageCode,
            prompt: 'What does “${word.text}” mean?',
            options: options,
            correctIndex: options.indexOf(word.translation),
          );
        }
        final options = _options(word, pool, (w) => w.text);
        return QuizQuestion(
          id: id,
          type: type,
          languageCode: word.languageCode,
          prompt: 'How do you say “${word.translation}”?',
          options: options,
          correctIndex: options.indexOf(word.text),
        );

      case QuizType.listenAndChoose:
        final options = _options(word, pool, (w) => w.text);
        return QuizQuestion(
          id: id,
          type: type,
          languageCode: word.languageCode,
          prompt: 'Tap the speaker and choose what you hear',
          audioText: word.text,
          options: options,
          correctIndex: options.indexOf(word.text),
        );

      case QuizType.fillInBlank:
        final sentence = blankSentence(word);
        // Not every example contains the exact word; fall back gracefully.
        if (sentence == null) {
          return _build(QuizType.multipleChoice, word, pool, index);
        }
        final options = _options(word, pool, (w) => w.text);
        return QuizQuestion(
          id: id,
          type: type,
          languageCode: word.languageCode,
          prompt: 'Complete the sentence',
          sentence: sentence,
          hint: word.exampleTranslation,
          options: options,
          correctIndex: options.indexOf(word.text),
        );

      case QuizType.matchPairs:
        final others = _distinctOthers(word, pool, 3);
        final pairs = [
          word,
          ...others,
        ].map((w) => MatchPair(w.text, w.translation)).toList();
        return QuizQuestion(
          id: id,
          type: type,
          languageCode: word.languageCode,
          prompt: 'Match the words with their Somali meaning',
          pairs: pairs,
        );
    }
  }

  /// Returns the example sentence with the word replaced by `_____`,
  /// or `null` if the word does not appear as a whole word.
  static String? blankSentence(Word word) {
    final pattern = RegExp(
      '(?<!\\p{L})${RegExp.escape(word.text)}(?!\\p{L})',
      caseSensitive: false,
      unicode: true,
    );
    if (!pattern.hasMatch(word.example)) return null;
    return word.example.replaceFirst(pattern, '_____');
  }

  /// The correct value plus up to 3 distractors, shuffled.
  /// Distractors from the same topic are preferred (harder, more useful).
  List<String> _options(Word answer, List<Word> pool, String Function(Word) f) {
    final correct = f(answer);
    final others = _distinctOthers(answer, pool, 3, f);
    return [correct, ...others.map(f)]..shuffle(_rng);
  }

  List<Word> _distinctOthers(
    Word answer,
    List<Word> pool,
    int n, [
    String Function(Word)? f,
  ]) {
    final key = f ?? (Word w) => '${w.text}|${w.translation}';
    final sameTopic =
        pool
            .where((w) => w.topicId == answer.topicId && w.id != answer.id)
            .toList()
          ..shuffle(_rng);
    final rest =
        pool
            .where((w) => w.topicId != answer.topicId && w.id != answer.id)
            .toList()
          ..shuffle(_rng);

    final seen = <String>{key(answer), answer.text, answer.translation};
    final picked = <Word>[];
    for (final w in [...sameTopic, ...rest]) {
      if (picked.length == n) break;
      if (seen.contains(key(w)) ||
          seen.contains(w.text) ||
          seen.contains(w.translation)) {
        continue;
      }
      seen
        ..add(key(w))
        ..add(w.text)
        ..add(w.translation);
      picked.add(w);
    }
    return picked;
  }
}
