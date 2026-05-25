import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../repositories/lesson_repository.dart';
import 'chemistry_provider.dart';

/// Provider that manages localized lesson content, navigation, and quiz sessions.
/// Integrates with [ChemistryProvider] to commit points on quiz completion.
class LessonProvider extends ChangeNotifier {
  final LessonRepository _repository;
  final ChemistryProvider _chemistryProvider;

  List<Lesson> _lessons = [];
  List<Lesson> get lessons => _lessons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentLessonIndex = 0;
  int get currentLessonIndex => _currentLessonIndex;

  // Quiz State
  int _currentQuizIndex = 0;
  int get currentQuizIndex => _currentQuizIndex;

  int? _selectedAnswerIndex;
  int? get selectedAnswerIndex => _selectedAnswerIndex;

  bool _isAnswerSubmitted = false;
  bool get isAnswerSubmitted => _isAnswerSubmitted;

  int _sessionScore = 0;
  int get sessionScore => _sessionScore;

  String _currentLocale = 'en';
  String get currentLocale => _currentLocale;

  bool get isSinhala => _currentLocale == 'si';

  // Badge Logic State
  bool _hasMastered = false;
  bool get hasMastered => _hasMastered;

  int _correctAnswersCount = 0;
  int get correctAnswersCount => _correctAnswersCount;

  LessonProvider({
    required LessonRepository repository,
    required ChemistryProvider chemistryProvider,
  }) : _repository = repository,
       _chemistryProvider = chemistryProvider;

  /// Updates the provider's active locale.
  void updateLocale(String localeCode) {
    if (_currentLocale != localeCode) {
      _currentLocale = localeCode;
      notifyListeners();
    }
  }

  /// Loads lessons using the repository and resets quiz state.
  Future<void> loadLessons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lessons = await _repository.getLessons();
      _currentLessonIndex = 0;
      resetQuizState();
    } catch (e) {
      _errorMessage = 'Failed to load lessons: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Changes the currently active lesson and resets quiz state.
  void setLessonIndex(int index) {
    if (index >= 0 && index < _lessons.length) {
      _currentLessonIndex = index;
      resetQuizState();
      notifyListeners();
    }
  }

  /// Returns the current active lesson.
  Lesson? get currentLesson {
    if (_lessons.isEmpty ||
        _currentLessonIndex < 0 ||
        _currentLessonIndex >= _lessons.length) {
      return null;
    }
    return _lessons[_currentLessonIndex];
  }

  /// Returns the current quiz question in the active lesson.
  LessonQuiz? get currentQuiz {
    final lesson = currentLesson;
    if (lesson == null || lesson.quizzes.isEmpty) return null;
    if (_currentQuizIndex < 0 || _currentQuizIndex >= lesson.quizzes.length) {
      return null;
    }
    return lesson.quizzes[_currentQuizIndex];
  }

  /// Sets the user's selected answer index.
  void selectAnswer(int index) {
    if (!_isAnswerSubmitted) {
      _selectedAnswerIndex = index;
      notifyListeners();
    }
  }

  /// Submits the user's selected answer. Returns true if correct.
  bool submitAnswer() {
    final lesson = currentLesson;
    final quiz = currentQuiz;

    if (lesson == null ||
        quiz == null ||
        _selectedAnswerIndex == null ||
        _isAnswerSubmitted) {
      return false;
    }

    _isAnswerSubmitted = true;
    final isCorrect = _selectedAnswerIndex == quiz.correctOptionIndex;

    if (isCorrect) {
      _sessionScore += quiz.points;
      _correctAnswersCount++;

      // Check if all questions in the lesson were answered correctly
      if (_correctAnswersCount == lesson.quizzes.length) {
        _hasMastered = true;
      }
    }

    notifyListeners();
    return isCorrect;
  }

  /// Advances to the next quiz question in the active lesson.
  bool nextQuestion() {
    final lesson = currentLesson;
    if (lesson == null) return false;

    if (_currentQuizIndex + 1 < lesson.quizzes.length) {
      _currentQuizIndex++;
      _selectedAnswerIndex = null;
      _isAnswerSubmitted = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Commits custom points to the global score in [ChemistryProvider].
  void commitScore(int quizPoints) {
    _chemistryProvider.addPoints(quizPoints);
    notifyListeners();
  }

  /// Resets the quiz session state for the active lesson.
  void resetQuizState() {
    _currentQuizIndex = 0;
    _selectedAnswerIndex = null;
    _isAnswerSubmitted = false;
    _sessionScore = 0;
    _correctAnswersCount = 0;
    _hasMastered = false;
    notifyListeners();
  }
}
