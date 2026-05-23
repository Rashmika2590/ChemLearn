/// Represents a chemistry lesson covering a specific topic.
///
/// Each lesson has a [title], rich [content] text, a difficulty [level],
/// and a list of [relatedReactions] IDs that the student can practice.
class Lesson {
  final String id;
  final String title;
  final String content;
  final int level;
  final List<String> relatedReactions; // Reaction IDs

  const Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.level,
    required this.relatedReactions,
  });

  /// Creates a [Lesson] from a Firestore document map.
  factory Lesson.fromMap(String id, Map<String, dynamic> map) {
    return Lesson(
      id: id,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      level: map['level'] as int? ?? 1,
      relatedReactions: List<String>.from(map['related_reactions'] ?? []),
    );
  }

  /// Serializes the lesson to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'level': level,
      'related_reactions': relatedReactions,
    };
  }

  @override
  String toString() => 'Lesson($title, level $level)';
}
