import 'language.dart';

/// One row of a lesson's examples table.
class GrammarExample {
  const GrammarExample(this.sentence, this.translation);

  final String sentence;

  /// Somali translation.
  final String translation;

  factory GrammarExample.fromJson(Map<String, dynamic> json) =>
      GrammarExample(json['sentence'] as String, json['translation'] as String);

  Map<String, dynamic> toJson() => {
    'sentence': sentence,
    'translation': translation,
  };
}

/// The short multiple-choice exercise at the end of a lesson.
class GrammarExercise {
  const GrammarExercise({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  String get correctAnswer => options[correctIndex];

  factory GrammarExercise.fromJson(Map<String, dynamic> json) =>
      GrammarExercise(
        prompt: json['prompt'] as String,
        options: List<String>.from(json['options'] as List),
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String,
      );

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
  };
}

/// A grammar lesson with explanation, rule, examples and practice.
class GrammarLesson {
  const GrammarLesson({
    required this.id,
    required this.languageCode,
    required this.order,
    required this.title,
    required this.description,
    required this.level,
    required this.explanation,
    required this.rule,
    required this.examples,
    required this.exercise,
  });

  final String id;
  final String languageCode;
  final int order;
  final String title;
  final String description;
  final LanguageLevel level;
  final String explanation;

  /// The key rule, shown highlighted.
  final String rule;
  final List<GrammarExample> examples;
  final GrammarExercise exercise;

  factory GrammarLesson.fromJson(Map<String, dynamic> json) => GrammarLesson(
    id: json['id'] as String,
    languageCode: json['languageCode'] as String,
    order: json['order'] as int,
    title: json['title'] as String,
    description: json['description'] as String,
    level: LanguageLevel.fromName(json['level'] as String?),
    explanation: json['explanation'] as String,
    rule: json['rule'] as String,
    examples: (json['examples'] as List)
        .map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
        .toList(),
    exercise: GrammarExercise.fromJson(
      json['exercise'] as Map<String, dynamic>,
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'languageCode': languageCode,
    'order': order,
    'title': title,
    'description': description,
    'level': level.name,
    'explanation': explanation,
    'rule': rule,
    'examples': examples.map((e) => e.toJson()).toList(),
    'exercise': exercise.toJson(),
  };
}
