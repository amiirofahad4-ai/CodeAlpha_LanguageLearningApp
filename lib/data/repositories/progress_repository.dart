import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/progress.dart';

/// Stores learner progress. Replace with Firestore later
/// (e.g. `users/{uid}/progress`).
abstract interface class ProgressRepository {
  Future<UserProgress> load(String userId);
  Future<void> save(String userId, UserProgress progress);
}

/// Saves progress as JSON in shared_preferences, one entry per user.
class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._prefs);

  final SharedPreferences _prefs;

  String _key(String userId) => 'progress.$userId';

  @override
  Future<UserProgress> load(String userId) async {
    final raw = _prefs.getString(_key(userId));
    if (raw == null) return const UserProgress();
    return UserProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(String userId, UserProgress progress) =>
      _prefs.setString(_key(userId), jsonEncode(progress.toJson()));
}
