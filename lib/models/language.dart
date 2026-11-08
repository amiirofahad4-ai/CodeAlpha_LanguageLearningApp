/// How advanced the learner is. Also used as a lesson difficulty.
enum LanguageLevel {
  beginner('Beginner', 'Bilow', 'I am just starting out'),
  intermediate('Intermediate', 'Dhexe', 'I know the basics'),
  advanced('Advanced', 'Sare', 'I can hold a conversation');

  const LanguageLevel(this.label, this.somaliLabel, this.description);

  final String label;
  final String somaliLabel;
  final String description;

  static LanguageLevel fromName(String? name) => LanguageLevel.values
      .firstWhere((l) => l.name == name, orElse: () => LanguageLevel.beginner);
}

/// A language the user can learn.
class Language {
  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.ttsLocale,
    this.isAvailable = true,
  });

  /// ISO code, e.g. `en`, `ar`.
  final String code;
  final String name;
  final String nativeName;

  /// Emoji flag shown on cards.
  final String flag;

  /// Locale passed to text-to-speech, e.g. `en-US`.
  final String ttsLocale;

  /// `false` = shown as "Coming soon".
  final bool isAvailable;

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    code: json['code'] as String,
    name: json['name'] as String,
    nativeName: json['nativeName'] as String,
    flag: json['flag'] as String,
    ttsLocale: json['ttsLocale'] as String,
    isAvailable: json['isAvailable'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'nativeName': nativeName,
    'flag': flag,
    'ttsLocale': ttsLocale,
    'isAvailable': isAvailable,
  };
}
