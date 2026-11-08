import 'package:flutter/foundation.dart';

import '../data/repositories/auth_repository.dart';
import '../models/user.dart';

/// Holds the signed-in user. Methods return an error message, or `null`
/// on success, so screens can show it directly.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  AppUser? _user;
  bool _isBusy = false;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isBusy => _isBusy;

  /// Restores the previous session. Call once at startup.
  Future<void> init() async {
    try {
      _user = await _repository.currentUser();
    } catch (e) {
      debugPrint('Could not restore session: $e');
      _user = null;
    }
    notifyListeners();
  }

  Future<String?> signIn(String email, String password) =>
      _run(() => _repository.signIn(email: email, password: password));

  Future<String?> register(String name, String email, String password) => _run(
    () => _repository.register(name: name, email: email, password: password),
  );

  Future<String?> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<String?> updateName(String name) {
    final current = _user;
    if (current == null) return Future.value('You are not signed in.');
    return _run(() => _repository.updateName(current, name));
  }

  Future<String?> sendPasswordReset(String email) async {
    _setBusy(true);
    try {
      await _repository.sendPasswordReset(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e, st) {
      debugPrint('$e\n$st');
      return 'Something went wrong. Please try again.';
    } finally {
      _setBusy(false);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    notifyListeners();
  }

  Future<String?> _run(Future<AppUser> Function() action) async {
    _setBusy(true);
    try {
      _user = await action();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e, st) {
      debugPrint('$e\n$st');
      return 'Something went wrong. Please try again.';
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
