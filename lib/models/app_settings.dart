import 'package:flutter/material.dart';

import '../core/constants.dart';
import 'language.dart';

/// User preferences stored on the device.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.onboardingSeen = false,
    this.languageCode,
    this.level = LanguageLevel.beginner,
    this.dailyGoal = AppConstants.defaultDailyGoal,
    this.remindersEnabled = true,
    this.reminderTime = const TimeOfDay(hour: 19, minute: 0),
  });

  final ThemeMode themeMode;
  final bool onboardingSeen;

  /// `null` until the user picks a language.
  final String? languageCode;
  final LanguageLevel level;

  /// XP per day.
  final int dailyGoal;
  final bool remindersEnabled;
  final TimeOfDay reminderTime;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? onboardingSeen,
    String? languageCode,
    LanguageLevel? level,
    int? dailyGoal,
    bool? remindersEnabled,
    TimeOfDay? reminderTime,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      languageCode: languageCode ?? this.languageCode,
      level: level ?? this.level,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: ThemeMode.values.firstWhere(
      (m) => m.name == json['themeMode'],
      orElse: () => ThemeMode.system,
    ),
    onboardingSeen: json['onboardingSeen'] as bool? ?? false,
    languageCode: json['languageCode'] as String?,
    level: LanguageLevel.fromName(json['level'] as String?),
    dailyGoal: json['dailyGoal'] as int? ?? AppConstants.defaultDailyGoal,
    remindersEnabled: json['remindersEnabled'] as bool? ?? true,
    reminderTime: TimeOfDay(
      hour: json['reminderHour'] as int? ?? 19,
      minute: json['reminderMinute'] as int? ?? 0,
    ),
  );

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'onboardingSeen': onboardingSeen,
    'languageCode': languageCode,
    'level': level.name,
    'dailyGoal': dailyGoal,
    'remindersEnabled': remindersEnabled,
    'reminderHour': reminderTime.hour,
    'reminderMinute': reminderTime.minute,
  };
}
