import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import '../models/lesson_model.dart';

/// Repository that loads and deserializes localized lessons and quizzes from local assets.
class LessonRepository {
  final String _assetPath;

  LessonRepository({String assetPath = 'assets/data/lessons.json'})
    : _assetPath = assetPath;

  /// Loads localized lessons from the JSON asset file.
  Future<List<Lesson>> getLessons() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      // මෙතන අනිවාර්යයෙන්ම List<dynamic> එකක් විදිහට decode කරන්න
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      // මෙතනදී item එක Map එකක් කියලා cast කරන්න
      return jsonList.map((item) {
        return Lesson.fromJson(item as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('🚨 Error loading lessons from $_assetPath: $e');
      return [];
    }
  }
}
