import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/compound.dart';
import '../models/reaction.dart';
import '../models/lesson.dart';

/// Handles all direct communication with Firebase Firestore.
///
/// This service is the *only* layer that imports `cloud_firestore`.
/// Repositories consume it, so the rest of the app stays decoupled
/// from the Firebase SDK.
class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ── Compounds ─────────────────────────────────────────────

  /// Fetches all compounds from Firestore.
  Future<List<Compound>> getCompounds() async {
    final snapshot =
        await _db.collection(AppConstants.compoundsCollection).get();
    return snapshot.docs
        .map((doc) => Compound.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Seeds the Firestore compounds collection from local data.
  Future<void> seedCompounds(List<Compound> compounds) async {
    final batch = _db.batch();
    for (final compound in compounds) {
      final ref = _db
          .collection(AppConstants.compoundsCollection)
          .doc(compound.id);
      batch.set(ref, compound.toMap());
    }
    await batch.commit();
  }

  // ── Reactions ─────────────────────────────────────────────

  /// Fetches all reactions from Firestore.
  Future<List<Reaction>> getReactions() async {
    final snapshot =
        await _db.collection(AppConstants.reactionsCollection).get();
    return snapshot.docs
        .map((doc) => Reaction.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Seeds the Firestore reactions collection from local data.
  Future<void> seedReactions(List<Reaction> reactions) async {
    final batch = _db.batch();
    for (final reaction in reactions) {
      final ref =
          _db.collection(AppConstants.reactionsCollection).doc(reaction.id);
      batch.set(ref, reaction.toMap());
    }
    await batch.commit();
  }

  // ── Lessons ───────────────────────────────────────────────

  /// Fetches all lessons from Firestore.
  Future<List<Lesson>> getLessons() async {
    final snapshot =
        await _db.collection(AppConstants.lessonsCollection).get();
    return snapshot.docs
        .map((doc) => Lesson.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Seeds the Firestore lessons collection from local data.
  Future<void> seedLessons(List<Lesson> lessons) async {
    final batch = _db.batch();
    for (final lesson in lessons) {
      final ref =
          _db.collection(AppConstants.lessonsCollection).doc(lesson.id);
      batch.set(ref, lesson.toMap());
    }
    await batch.commit();
  }
}
