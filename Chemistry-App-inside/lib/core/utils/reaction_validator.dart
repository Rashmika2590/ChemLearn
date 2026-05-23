import '../../models/compound.dart';
import '../../models/reaction.dart';

/// Result of a reaction validation attempt.
///
/// If [isCorrect] is `true`, [product] and [explanation] contain
/// the successful reaction details. Otherwise [hintMessage] suggests
/// what to try instead.
class ReactionResult {
  final bool isCorrect;
  final Compound? product;
  final String? explanation;
  final String? reactionType;
  final String? hintMessage;

  const ReactionResult({
    required this.isCorrect,
    this.product,
    this.explanation,
    this.reactionType,
    this.hintMessage,
  });

  /// Convenience factory for a successful match.
  factory ReactionResult.success({
    required Compound product,
    required String explanation,
    required String reactionType,
  }) {
    return ReactionResult(
      isCorrect: true,
      product: product,
      explanation: explanation,
      reactionType: reactionType,
    );
  }

  /// Convenience factory for a failed attempt.
  factory ReactionResult.failure(String hint) {
    return ReactionResult(
      isCorrect: false,
      hintMessage: hint,
    );
  }
}

/// Pure-logic service that validates reactions locally in memory.
///
/// This is the **core validation engine**. It does NOT call Firestore.
/// All reactions are pre-loaded and passed in so lookups are O(n)
/// with a small n.
class ReactionValidator {
  final List<Reaction> _reactions;
  final List<Compound> _compounds;

  ReactionValidator({
    required List<Reaction> reactions,
    required List<Compound> compounds,
  })  : _reactions = reactions,
        _compounds = compounds;

  /// Validates whether the chosen [reactantIds] + [condition] produce
  /// a valid reaction.
  ///
  /// Matching is **order-independent** for reactants.
  ReactionResult validate({
    required List<String> reactantIds,
    required String condition,
  }) {
    // Remove empty / null entries
    final ids = reactantIds.where((id) => id.isNotEmpty).toList()..sort();

    if (ids.isEmpty) {
      return ReactionResult.failure('Please select at least one reactant.');
    }

    // Search for a matching reaction
    for (final reaction in _reactions) {
      final sortedReactionReactants = List<String>.from(reaction.reactants)
        ..sort();

      // Check reactant match (order-independent)
      final reactantsMatch = _listEquals(ids, sortedReactionReactants);

      // Check condition match (case-insensitive, partial)
      final conditionMatch = reaction.conditions.any(
        (c) => c.toLowerCase() == condition.toLowerCase(),
      );

      if (reactantsMatch && conditionMatch) {
        // Found a valid reaction — resolve product compound
        final product = _compoundById(reaction.product);
        if (product != null) {
          return ReactionResult.success(
            product: product,
            explanation: reaction.explanation,
            reactionType: reaction.type,
          );
        }
      }
    }

    // No match found — generate a helpful hint
    return ReactionResult.failure(_generateHint(ids, condition));
  }

  /// Generates a contextual hint for incorrect attempts.
  String _generateHint(List<String> reactantIds, String condition) {
    // Check if the reactants appear in any reaction
    for (final reaction in _reactions) {
      final sorted = List<String>.from(reaction.reactants)..sort();
      if (_listEquals(reactantIds, sorted)) {
        // Reactants match but condition is wrong
        return 'These reactants can react, but you need a different condition. '
            'Try: ${reaction.conditions.join(", ")}';
      }
    }

    // No reactant match at all
    final names = reactantIds
        .map((id) => _compoundById(id)?.name ?? id)
        .join(' and ');
    return 'No known reaction between $names under this condition. '
        'Try different reactants or check the lessons for hints!';
  }

  /// Look up a compound by ID from the in-memory list.
  Compound? _compoundById(String id) {
    try {
      return _compounds.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Simple list equality check for sorted string lists.
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Returns all distinct conditions used across reactions.
  List<String> get allConditions {
    final set = <String>{};
    for (final r in _reactions) {
      set.addAll(r.conditions);
    }
    return set.toList()..sort();
  }
}
