import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/user.dart';
import 'auth_repository.dart';

/// Real authentication with Firebase Auth.
///
/// Each user also gets a profile document at `users/{uid}`.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Future<AppUser?> currentUser() async {
    // Firebase restores the session on its own; wait for the first event.
    final user = _auth.currentUser ?? await _auth.authStateChanges().first;
    return user == null ? null : _toAppUser(user);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) => _guard(() async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _toAppUser(cred.user!);
  });

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await _saveProfile(user, name: name.trim(), isNew: true);
    return _toAppUser(user, name: name.trim());
  });

  @override
  Future<AppUser> signInWithGoogle() => _guard(() async {
    final provider = GoogleAuthProvider()..addScope('email');
    final cred = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);
    final user = cred.user!;
    await _saveProfile(
      user,
      name: user.displayName ?? '',
      isNew: cred.additionalUserInfo?.isNewUser ?? false,
    );
    return _toAppUser(user);
  });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<AppUser> updateName(AppUser user, String name) => _guard(() async {
    final current = _auth.currentUser;
    if (current == null) throw const AuthException('You are not signed in.');
    await current.updateDisplayName(name.trim());
    await _userDoc(current.uid).set({
      'name': name.trim(),
    }, SetOptions(merge: true));
    return user.copyWith(name: name.trim());
  });

  @override
  Future<void> signOut() => _auth.signOut();

  // ---------------------------------------------------------------- helpers

  /// Creates or updates `users/{uid}`. A failed write must not block login.
  Future<void> _saveProfile(
    User user, {
    required String name,
    required bool isNew,
  }) async {
    try {
      await _userDoc(user.uid).set({
        'name': name,
        'email': user.email,
        'photoUrl': user.photoURL,
        if (isNew) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Could not save user profile: $e');
    }
  }

  AppUser _toAppUser(User user, {String? name}) {
    final email = user.email ?? '';
    final displayName = name ?? user.displayName;
    return AppUser(
      id: user.uid,
      name: (displayName == null || displayName.trim().isEmpty)
          ? email.split('@').first
          : displayName,
      email: email,
      avatarUrl: user.photoURL,
    );
  }

  /// Turns Firebase errors into messages that are safe to show.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  String _message(String code) => switch (code) {
    'invalid-email' => 'This email address is not valid.',
    'user-disabled' => 'This account has been disabled.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Incorrect email or password.',
    'email-already-in-use' => 'An account with this email already exists.',
    'weak-password' => 'Password is too weak. Use at least 6 characters.',
    'too-many-requests' => 'Too many attempts. Please wait and try again.',
    'network-request-failed' => 'No internet connection. Please try again.',
    'popup-closed-by-user' ||
    'web-context-canceled' ||
    'canceled' => 'Google sign-in was cancelled.',
    'operation-not-allowed' =>
      'This sign-in method is not enabled in Firebase.',
    _ => 'Something went wrong ($code). Please try again.',
  };
}
