import '../models/compound.dart';
import '../models/reaction.dart';
import '../models/lesson.dart';
import '../services/firestore_service.dart';
import '../data/seed_data.dart';

/// Repository that provides chemistry data to the app.
///
/// It attempts to load data from Firestore first. If Firestore is
/// empty or unavailable, it falls back to [SeedData].
/// Once loaded, all data is cached in memory so the app never
/// re-fetches data unless explicitly refreshed.
class ChemistryRepository {
  final FirestoreService _firestoreService;

  // In-memory caches
  List<Compound>? _compounds;
  List<Reaction>? _reactions;
  List<Lesson>? _lessons;

  ChemistryRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  // ── Compounds ─────────────────────────────────────────────

  /// Returns all compounds, loading from Firestore or seed data.
  Future<List<Compound>> getCompounds({bool forceRefresh = false}) async {
    if (_compounds != null && !forceRefresh) return _compounds!;

    try {
      final data = await _firestoreService.getCompounds();
      if (data.isNotEmpty) {
        _compounds = data;
        return _compounds!;
      }
    } catch (_) {
      // Firestore unavailable — fall through to seed data
    }

    _compounds = SeedData.compounds;
    return _compounds!;
  }

  /// Looks up a compound by its [id].
  Future<Compound?> getCompoundById(String id) async {
    final all = await getCompounds();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Reactions ─────────────────────────────────────────────

  /// Returns all reactions, loading from Firestore or seed data.
  Future<List<Reaction>> getReactions({bool forceRefresh = false}) async {
    if (_reactions != null && !forceRefresh) return _reactions!;

    try {
      final data = await _firestoreService.getReactions();
      if (data.isNotEmpty) {
        _reactions = data;
        return _reactions!;
      }
    } catch (_) {
      // Fall through to seed data
    }

    _reactions = SeedData.reactions;
    return _reactions!;
  }

  // ── Lessons ───────────────────────────────────────────────

  /// Returns all lessons, loading from Firestore or seed data.
  Future<List<Lesson>> getLessons({bool forceRefresh = false}) async {
    if (_lessons != null && !forceRefresh) return _lessons!;

    try {
      final data = await _firestoreService.getLessons();
      if (data.isNotEmpty) {
        _lessons = data;
        return _lessons!;
      }
    } catch (_) {
      // Fall through to seed data
    }

    _lessons = SeedData.lessons;
    return _lessons!;
  }

  // ── Seed Firestore ────────────────────────────────────────

  /// Pushes seed data to Firestore (useful for initial setup).
  Future<void> seedFirestore() async {
    await _firestoreService.seedCompounds(SeedData.compounds);
    await _firestoreService.seedReactions(SeedData.reactions);
    await _firestoreService.seedLessons(SeedData.lessons);
  }
}
