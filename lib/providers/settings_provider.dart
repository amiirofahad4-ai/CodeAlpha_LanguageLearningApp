import 'package:flutter/material.dart';

import '../data/repositories/settings_repository.dart';
import '../models/app_settings.dart';
import '../models/language.dart';

/// App preferences: theme, chosen language/level, daily goal, reminders.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repository);

  final SettingsRepository _repository;
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  bool get onboardingSeen => _settings.onboardingSeen;
  String? get languageCode => _settings.languageCode;
  bool get hasLanguage => _settings.languageCode != null;
  LanguageLevel get level => _settings.level;
  int get dailyGoal => _settings.dailyGoal;
  bool get remindersEnabled => _settings.remindersEnabled;
  TimeOfDay get reminderTime => _settings.reminderTime;

  Future<void> load() async {
    try {
      _settings = await _repository.load();
    } catch (e) {
      debugPrint('Could not load settings: $e');
    }
    notifyListeners();
  }

  Future<void> _update(AppSettings next) async {
    _settings = next;
    notifyListeners();
    await _repository.save(next);
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(_settings.copyWith(themeMode: mode));

  Future<void> completeOnboarding() =>
      _update(_settings.copyWith(onboardingSeen: true));

  Future<void> setLanguage(String code, LanguageLevel level) =>
      _update(_settings.copyWith(languageCode: code, level: level));

  Future<void> setLevel(LanguageLevel level) =>
      _update(_settings.copyWith(level: level));

  Future<void> setDailyGoal(int xp) =>
      _update(_settings.copyWith(dailyGoal: xp));

  Future<void> setRemindersEnabled(bool enabled) =>
      _update(_settings.copyWith(remindersEnabled: enabled));

  Future<void> setReminderTime(TimeOfDay time) =>
      _update(_settings.copyWith(reminderTime: time));
}
