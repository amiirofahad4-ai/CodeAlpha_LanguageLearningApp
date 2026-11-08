/// A word or short phrase with its Somali translation.
class Word {
  const Word({
    required this.id,
    required this.topicId,
    required this.languageCode,
    required this.text,
    required this.phonetic,
    required this.translation,
    required this.example,
    required this.exampleTranslation,
    required this.emoji,
    this.imageUrl,
  });

  final String id;
  final String topicId;
  final String languageCode;

  /// The word in the language being learned.
  final String text;

  /// Pronunciation hint, e.g. `/ˈmʌðər/`.
  final String phonetic;

  /// Somali translation.
  final String translation;

  final String example;
  final String exampleTranslation;

  /// Used as the picture until real images ([imageUrl]) are added.
  final String emoji;
  final String? imageUrl;

  factory Word.fromJson(Map<String, dynamic> json) => Word(
    id: json['id'] as String,
    topicId: json['topicId'] as String,
    languageCode: json['languageCode'] as String,
    text: json['text'] as String,
    phonetic: json['phonetic'] as String,
    translation: json['translation'] as String,
    example: json['example'] as String,
    exampleTranslation: json['exampleTranslation'] as String,
    emoji: json['emoji'] as String,
    imageUrl: json['imageUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'topicId': topicId,
    'languageCode': languageCode,
    'text': text,
    'phonetic': phonetic,
    'translation': translation,
    'example': example,
    'exampleTranslation': exampleTranslation,
    'emoji': emoji,
    'imageUrl': imageUrl,
  };
}
