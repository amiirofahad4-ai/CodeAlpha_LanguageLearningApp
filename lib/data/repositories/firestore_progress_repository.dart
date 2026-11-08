import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/progress.dart';
import 'progress_repository.dart';

/// Saves progress in Firestore at `users/{uid}/progress/summary`,
/// and keeps a copy on the phone through [local].
///
/// * Save: phone first (instant), then Firestore.
/// * Load: Firestore if reachable, otherwise the phone copy.
class FirestoreProgressRepository implements ProgressRepository {
  FirestoreProgressRepository({
    required this._local,
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  final ProgressRepository _local;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('progress').doc('summary');

  @override
  Future<UserProgress> load(String userId) async {
    try {
      final snap = await _doc(userId).get();
      final data = snap.data();
      if (data != null) {
        final progress = UserProgress.fromJson(data);
        await _local.save(userId, progress);
        return progress;
      }
      // First time on Firebase: upload anything saved on the phone.
      final localProgress = await _local.load(userId);
      if (localProgress.xp > 0) {
        unawaited(
          _upload(
            userId,
            localProgress,
          ).catchError((Object e) => debugPrint('Firestore upload failed: $e')),
        );
      }
      return localProgress;
    } catch (e) {
      debugPrint('Firestore load failed, using phone copy: $e');
      return _local.load(userId);
    }
  }

  @override
  Future<void> save(String userId, UserProgress progress) async {
    await _local.save(userId, progress);
    // Not awaited: offline, Firestore queues the write and its future only
    // completes once the server confirms, which would freeze the UI.
    unawaited(
      _upload(
        userId,
        progress,
      ).catchError((Object e) => debugPrint('Firestore save failed: $e')),
    );
  }

  Future<void> _upload(String userId, UserProgress progress) =>
      _doc(userId).set({
        ...progress.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
