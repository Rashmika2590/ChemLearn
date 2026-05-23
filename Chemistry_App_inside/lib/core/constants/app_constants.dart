/// Application-wide constants for the Chemistry Learning App.
///
/// Centralizes all magic strings and values to keep the codebase
/// maintainable and consistent.
class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ── App Info ──────────────────────────────────────────────
  static const String appName = 'ChemLearn';
  static const String appTagline = 'Master Organic Chemistry';

  // ── Firestore Collection Names ────────────────────────────
  static const String compoundsCollection = 'compounds';
  static const String reactionsCollection = 'reactions';
  static const String lessonsCollection = 'lessons';
  static const String usersCollection = 'users';

  // ── Scoring ───────────────────────────────────────────────
  static const int correctReactionPoints = 10;
  static const int hintPenaltyPoints = 3;

  // ── UI Strings ────────────────────────────────────────────
  static const String homeTitle = 'ChemLearn';
  static const String lessonsTitle = 'Lessons';
  static const String practiceTitle = 'Practice Lab';
  static const String scoreLabel = 'Score';

  // ── Feedback Messages ─────────────────────────────────────
  static const String correctMessage = '🎉 Correct! Great work!';
  static const String incorrectMessage =
      '❌ Not quite right. Check the hint below.';
  static const String selectAllMessage =
      'Please select a reactant, reagent, and condition.';

  // ── Compound Types ────────────────────────────────────────
  static const String typeAlkane = 'alkane';
  static const String typeAlkene = 'alkene';
  static const String typeAlkyne = 'alkyne';
  static const String typeAlcohol = 'alcohol';
  static const String typeHaloalkane = 'haloalkane';
  static const String typeAcid = 'acid';

  // ── Reaction Types ────────────────────────────────────────
  static const String reactionAddition = 'addition';
  static const String reactionSubstitution = 'substitution';
  static const String reactionElimination = 'elimination';
  static const String reactionCombustion = 'combustion';
}
