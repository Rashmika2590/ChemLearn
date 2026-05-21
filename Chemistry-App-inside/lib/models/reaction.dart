/// Represents a chemical reaction with its reactants, conditions, and product.
///
/// The [reactants] list contains compound IDs that participate in the
/// reaction. The [conditions] list describes required conditions
/// (e.g. "heat", "catalyst"). Matching is order-independent.
class Reaction {
  final String id;
  final List<String> reactants; // Compound IDs
  final List<String> conditions; // e.g. ["heat"], ["H2SO4 catalyst"]
  final String product; // Compound ID of the product
  final String type; // addition, substitution, elimination, combustion
  final String explanation;
  final int level;

  const Reaction({
    required this.id,
    required this.reactants,
    required this.conditions,
    required this.product,
    required this.type,
    required this.explanation,
    required this.level,
  });

  /// Creates a [Reaction] from a Firestore document map.
  factory Reaction.fromMap(String id, Map<String, dynamic> map) {
    return Reaction(
      id: id,
      reactants: List<String>.from(map['reactants'] ?? []),
      conditions: List<String>.from(map['conditions'] ?? []),
      product: map['product'] as String? ?? '',
      type: map['type'] as String? ?? '',
      explanation: map['explanation'] as String? ?? '',
      level: map['level'] as int? ?? 1,
    );
  }

  /// Serializes the reaction to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'reactants': reactants,
      'conditions': conditions,
      'product': product,
      'type': type,
      'explanation': explanation,
      'level': level,
    };
  }

  @override
  String toString() => 'Reaction($type: $reactants → $product)';
}
