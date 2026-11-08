import 'package:flutter/material.dart';

import '../core/utils/topic_icons.dart';

/// A vocabulary topic such as Family or Food.
class Topic {
  const Topic({
    required this.id,
    required this.languageCode,
    required this.title,
    required this.somaliTitle,
    required this.iconName,
    required this.colorValue,
    required this.wordCount,
  });

  final String id;
  final String languageCode;
  final String title;
  final String somaliTitle;
  final String iconName;
  final int colorValue;
  final int wordCount;

  Color get color => Color(colorValue);
  IconData get icon => TopicIcons.of(iconName);

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
    id: json['id'] as String,
    languageCode: json['languageCode'] as String,
    title: json['title'] as String,
    somaliTitle: json['somaliTitle'] as String,
    iconName: json['iconName'] as String,
    colorValue: json['colorValue'] as int,
    wordCount: json['wordCount'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'languageCode': languageCode,
    'title': title,
    'somaliTitle': somaliTitle,
    'iconName': iconName,
    'colorValue': colorValue,
    'wordCount': wordCount,
  };
}
