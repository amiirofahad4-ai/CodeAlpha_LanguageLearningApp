import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../models/user.dart';

/// Thrown by an [AuthRepository] with a message safe to show the user.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Authentication API. Swap [MockAuthRepository] for a
/// `FirebaseAuthRepository` later — the interface stays the same.
abstract interface class AuthRepository {
  /// The user restored from the last session, if any.
  Future<AppUser?> currentUser();

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<AppUser> updateName(AppUser user, String name);

  Future<void> signOut();
}

/// Fake auth that keeps accounts in shared_preferences.
///
/// Demo rules:
/// * Any valid email + password (6+ chars) signs in.
/// * If the email was registered, the password must match.
/// * The email `error@test.com` always fails (to preview error states).
class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _userKey = 'auth.currentUser';
  static const _accountsKey = 'auth.accounts';

  Future<void> _delay() =>
      Future<void>.delayed(AppConstants.mockNetworkDelay * 2);

  Map<String, dynamic> get _accounts =>
      jsonDecode(_prefs.getString(_accountsKey) ?? '{}')
          as Map<String, dynamic>;

  Future<AppUser> _saveSession(AppUser user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
    return user;
  }

  void _failIfTestEmail(String email) {
    if (email.toLowerCase() == 'error@test.com') {
      throw const AuthException('Network error. Please try again.');
    }
  }

  @override
  Future<AppUser?> currentUser() async {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await _delay();
    final key = email.trim().toLowerCase();
    _failIfTestEmail(key);

    final account = _accounts[key] as Map<String, dynamic>?;
    if (account != null && account['password'] != password) {
      throw const AuthException('Incorrect password. Please try again.');
    }
    final name = account?['name'] as String? ?? _nameFromEmail(key);
    return _saveSession(AppUser(id: key, name: name, email: key));
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _delay();
    final key = email.trim().toLowerCase();
    _failIfTestEmail(key);

    final accounts = _accounts;
    if (accounts.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }
    accounts[key] = {'name': name.trim(), 'password': password};
    await _prefs.setString(_accountsKey, jsonEncode(accounts));
    return _saveSession(AppUser(id: key, name: name.trim(), email: key));
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await _delay();
    return _saveSession(
      const AppUser(
        id: 'google-demo-user',
        name: 'Hodan Ali',
        email: 'hodan.ali@gmail.com',
      ),
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _delay();
    _failIfTestEmail(email.trim());
  }

  @override
  Future<AppUser> updateName(AppUser user, String name) async {
    await _delay();
    return _saveSession(user.copyWith(name: name.trim()));
  }

  @override
  Future<void> signOut() => _prefs.remove(_userKey);

  /// "hodan.ali@x.com" → "Hodan Ali"
  String _nameFromEmail(String email) => email
      .split('@')
      .first
      .split(RegExp(r'[._-]'))
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1))
      .join(' ');
}
