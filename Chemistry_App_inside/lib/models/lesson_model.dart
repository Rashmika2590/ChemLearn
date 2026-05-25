/// Models representing a localized chemistry lesson and its completion quiz.
/// Supports dual-language content (English and Sinhala).
class LocalizedContent {
  final String en;
  final String si;

  const LocalizedContent({
    required this.en,
    required this.si,
  });

  /// Creates a [LocalizedContent] from a JSON map.
  factory LocalizedContent.fromJson(Map<String, dynamic> json) {
    return LocalizedContent(
      en: json['en'] as String? ?? '',
      si: json['si'] as String? ?? '',
    );
  }

  /// Converts this localized content to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'si': si,
    };
  }

  /// Returns the string content based on the language code (e.g., 'en' or 'si').
  String get(String languageCode) {
    return languageCode == 'si' ? si : en;
  }

  @override
  String toString() => 'LocalizedContent(en: $en, si: $si)';
}

/// Represents a quiz associated with a lesson.
class LessonQuiz {
  final LocalizedContent question;
  final List<LocalizedContent> options;
  final int correctOptionIndex;
  final int points;

  const LessonQuiz({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.points,
  });

  /// Creates a [LessonQuiz] from a JSON map.
  factory LessonQuiz.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    final parsedOptions = rawOptions
        .map((opt) => LocalizedContent.fromJson(opt as Map<String, dynamic>))
        .toList();

    return LessonQuiz(
      question: LocalizedContent.fromJson(json['question'] as Map<String, dynamic>),
      options: parsedOptions,
      correctOptionIndex: json['correctOptionIndex'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
    );
  }

  /// Converts this lesson quiz to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'question': question.toJson(),
      'options': options.map((opt) => opt.toJson()).toList(),
      'correctOptionIndex': correctOptionIndex,
      'points': points,
    };
  }

  @override
  String toString() => 'LessonQuiz(question: $question, points: $points)';
}

/// Represents a dynamic, localized Chemistry Lesson loaded from local assets.
class Lesson {
  final String id;
  final LocalizedContent title;
  final LocalizedContent body;
  final int level;
  final List<String> relatedReactions;
  final List<LessonQuiz> quizzes;

  const Lesson({
    required this.id,
    required this.title,
    required this.body,
    required this.level,
    required this.relatedReactions,
    required this.quizzes,
  });

  /// Creates a [Lesson] from a JSON map.
  factory Lesson.fromJson(Map<String, dynamic> json) {
    final rawReactions = json['related_reactions'] as List<dynamic>? ?? [];
    final rawQuizzes = json['quizzes'] as List<dynamic>? ?? [];

    return Lesson(
      id: json['id'] as String? ?? '',
      title: LocalizedContent.fromJson(json['title'] as Map<String, dynamic>),
      body: LocalizedContent.fromJson(json['body'] as Map<String, dynamic>),
      level: json['level'] as int? ?? 1,
      relatedReactions: List<String>.from(rawReactions),
      quizzes: rawQuizzes
          .map((q) => LessonQuiz.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts this lesson to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title.toJson(),
      'body': body.toJson(),
      'level': level,
      'related_reactions': relatedReactions,
      'quizzes': quizzes.map((q) => q.toJson()).toList(),
    };
  }

  @override
  String toString() => 'Lesson(id: $id, title: $title)';
}
