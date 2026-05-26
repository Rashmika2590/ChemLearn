import 'dart:convert';
import 'package:chemistry_app/models/mcq_model.dart';
import 'package:flutter/services.dart';

class QuizService {
  static const String _jsonPath = 'assets/data/past_papers.json';

  // Cache for loaded data
  List<PastPaperYear>? _cachedPapers;

  /// Load all past papers from JSON file
  Future<List<PastPaperYear>> loadAllPapers() async {
    if (_cachedPapers != null) {
      return _cachedPapers!;
    }

    try {
      final String response = await rootBundle.loadString(_jsonPath);
      final List<dynamic> data = json.decode(response)['questions'];

      _cachedPapers = data.map((item) => PastPaperYear.fromJson(item)).toList();

      return _cachedPapers!;
    } catch (e) {
      throw Exception('Failed to load past papers: $e');
    }
  }

  /// Get paper by specific year
  Future<PastPaperYear?> getPaperByYear(int year) async {
    final allPapers = await loadAllPapers();

    try {
      return allPapers.firstWhere(
        (paper) => paper.year == year,
        orElse: () => throw Exception('Year $year not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all available years
  Future<List<int>> getAllYears() async {
    final allPapers = await loadAllPapers();
    return allPapers.map((paper) => paper.year).toList();
  }

  /// Get questions by year range
  Future<List<PastPaperYear>> getPapersByYearRange(
    int startYear,
    int endYear,
  ) async {
    final allPapers = await loadAllPapers();
    return allPapers
        .where((paper) => paper.year >= startYear && paper.year <= endYear)
        .toList();
  }

  /// Clear cache (useful for testing)
  void clearCache() {
    _cachedPapers = null;
  }
}
