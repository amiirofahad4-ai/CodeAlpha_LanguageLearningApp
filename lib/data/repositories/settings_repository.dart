import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_settings.dart';

/// Stores device preferences (theme, language, daily goal…).
abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'settings';

  @override
  Future<AppSettings> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(AppSettings settings) =>
      _prefs.setString(_key, jsonEncode(settings.toJson()));
}
