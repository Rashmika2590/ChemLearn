/// Represents a chemical compound used in lessons and reactions.
///
/// Each compound has a [name], chemical [formula], a classification
/// [type] (e.g. alkane, alkene, alcohol), a difficulty [level], and
/// a short [description].
class Compound {
  final String id;
  final String name;
  final String formula;
  final String type; // alkane, alkene, alcohol, haloalkane, acid, etc.
  final int level;
  final String description;

  const Compound({
    required this.id,
    required this.name,
    required this.formula,
    required this.type,
    required this.level,
    required this.description,
  });

  /// Creates a [Compound] from a Firestore document map.
  factory Compound.fromMap(String id, Map<String, dynamic> map) {
    return Compound(
      id: id,
      name: map['name'] as String? ?? '',
      formula: map['formula'] as String? ?? '',
      type: map['type'] as String? ?? '',
      level: map['level'] as int? ?? 1,
      description: map['description'] as String? ?? '',
    );
  }

  /// Serializes the compound to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'formula': formula,
      'type': type,
      'level': level,
      'description': description,
    };
  }

  @override
  String toString() => '$name ($formula)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Compound && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
