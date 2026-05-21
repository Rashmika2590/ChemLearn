import 'package:flutter/material.dart';

import '../models/compound.dart';
import '../models/lesson.dart';
import '../models/pubchem_compound.dart';
import '../repositories/chemistry_repository.dart';
import '../services/ai_service.dart';
import '../services/pubchem_service.dart';
import '../core/constants/app_constants.dart';

/// Local ReactionResult structure maintained for UI compatibility
class ReactionResult {
  final bool isCorrect;
  final String? message;
  final DynamicProduct? product;
  final String? reactionType;
  final String? explanation;
  final String? hintMessage;

  ReactionResult({
    required this.isCorrect,
    this.message,
    this.product,
    this.reactionType,
    this.explanation,
    this.hintMessage,
  });

  factory ReactionResult.failure(String message) {
    return ReactionResult(
      isCorrect: false,
      message: message,
      hintMessage: message,
    );
  }
}

/// Dynamic Product class to simulate old hardcoded product model in UI
class DynamicProduct {
  final String name;
  final String formula;
  DynamicProduct({required this.name, required this.formula});
}

/// A single message in the tutor chat.
class TutorMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  TutorMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

/// Manages all application state for the chemistry app.
/// 100% API-Driven and Dynamic via Groq AI & PubChem API.
class ChemistryProvider extends ChangeNotifier {
  final ChemistryRepository _repository;
  final AiService _aiService;
  final PubChemService _pubChemService;

  ChemistryProvider({
    required ChemistryRepository repository,
    required AiService aiService,
    required PubChemService pubChemService,
  }) : _repository = repository,
       _aiService = aiService,
       _pubChemService = pubChemService;

  // ── Loading State ─────────────────────────────────────────
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Data ──────────────────────────────────────────────────
  List<Compound> _compounds = [];
  List<Compound> get compounds => _compounds;

  List<Lesson> _lessons = [];
  List<Lesson> get lessons => _lessons;

  // ── Score ──────────────────────────────────────────────────
  int _score = 0;
  int get score => _score;

  int _totalAttempts = 0;
  int get totalAttempts => _totalAttempts;

  int _correctAttempts = 0;
  int get correctAttempts => _correctAttempts;

  // ── Completed Lessons ─────────────────────────────────────
  final Set<String> _completedLessonIds = {};
  Set<String> get completedLessonIds => _completedLessonIds;

  bool isLessonCompleted(String id) => _completedLessonIds.contains(id);

  void markLessonCompleted(String id) {
    _completedLessonIds.add(id);
    notifyListeners();
  }

  // ── Practice Lab State ────────────────────────────────────
  String? _selectedReactantA;
  String? get selectedReactantA => _selectedReactantA;

  String? _selectedReactantB;
  String? get selectedReactantB => _selectedReactantB;

  // මේ ටික ඔයාගේ දැනට තියෙන code එකේ variables වලට යටින් දාන්න
  String? get reactantA => _selectedReactantA;
  String? get reactantB => _selectedReactantB;

  String? _selectedCondition;
  String? get selectedCondition => _selectedCondition;

  ReactionResult? _lastResult;
  ReactionResult? get lastResult => _lastResult;

  // ── AI Enrichment State ───────────────────────────────────
  bool _isEnriching = false;
  bool get isEnriching => _isEnriching;

  String? _aiExplanation;
  String? get aiExplanation => _aiExplanation;

  PubChemCompound? _pubChemData;
  PubChemCompound? get pubChemData => _pubChemData;

  bool get isAiAvailable => _aiService.isAvailable;

  // ── Tutor Chat State ──────────────────────────────────────
  final List<TutorMessage> _tutorMessages = [];
  List<TutorMessage> get tutorMessages => List.unmodifiable(_tutorMessages);

  bool _isTutorTyping = false;
  bool get isTutorTyping => _isTutorTyping;

  // ── Initialization ────────────────────────────────────────

  /// Loads core compounds and lessons from repository.
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _compounds = await _repository.getCompounds();
      _lessons = await _repository.getLessons();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Practice Lab Actions ──────────────────────────────────

  void selectReactantA(String? id) {
    _selectedReactantA = id;
    _lastResult = null;
    _aiExplanation = null;
    _pubChemData = null;
    notifyListeners();
  }

  void selectReactantB(String? id) {
    _selectedReactantB = id;
    _lastResult = null;
    _aiExplanation = null;
    _pubChemData = null;
    notifyListeners();
  }

  void selectCondition(String? condition) {
    _selectedCondition = condition;
    _lastResult = null;
    _aiExplanation = null;
    _pubChemData = null;
    notifyListeners();
  }

  /// Provides static fallback conditions since old validator is removed
  List<String> get availableConditions {
    return [
      'Acid catalyst (H₂SO₄)',
      'H₃PO₄ catalyst',
      'UV Light',
      'Nickel catalyst, 180°C',
      'Room Temperature',
      'Alkaline KMnO₄',
    ];
  }

  /// 🎯 100% Dynamic Reaction Checker using Groq AI and PubChem API
  Future<void> checkReaction() async {
    // Build selected reactant list
    final reactantIds = <String>[
      if (_selectedReactantA != null) _selectedReactantA!,
      if (_selectedReactantB != null && _selectedReactantB!.isNotEmpty)
        _selectedReactantB!,
    ];

    if (reactantIds.isEmpty || _selectedCondition == null) {
      _lastResult = ReactionResult.failure(AppConstants.selectAllMessage);
      notifyListeners();
      return;
    }

    _isEnriching = true;
    _lastResult = null;
    _aiExplanation = null;
    _pubChemData = null;
    notifyListeners();

    final reactantNames = reactantIds
        .map((id) => compoundById(id)?.name ?? id)
        .toList();

    _totalAttempts++;

    try {
      // 1️⃣ Groq AI එකෙන් Response එක ලබා ගැනීම
      final aiResult = await _aiService.predictReaction(
        reactantNames: reactantNames,
        condition: _selectedCondition!,
      );

      if (aiResult != null &&
          aiResult['product_name'] != null &&
          aiResult['product_name'].toString().toLowerCase() != 'no reaction') {
        _correctAttempts++;
        _score += AppConstants.correctReactionPoints;

        final pName = aiResult['product_name'].toString();
        final pFormula = aiResult['formula']?.toString() ?? '';
        _aiExplanation = aiResult['explanation']?.toString() ?? '';

        // 2️⃣ PubChem API එකෙන් Product එකේ සැබෑ දත්ත ලබා ගැනීම
        final pubChemRaw = await _pubChemService.getCompound(pName);

        if (pubChemRaw != null) {
          _pubChemData = pubChemRaw;
        } else {
          // Fallback if PubChem doesn't return anything
          _pubChemData = PubChemCompound(
            cid: 0,
            iupacName: pName,
            molecularFormula: pFormula,
            molecularWeight: 0.0,
            description: _aiExplanation,
          );
        }

        // UI එකට ගැළපෙන ලෙස runtime එකේදී ReactionResult එක සෑදීම
        _lastResult = ReactionResult(
          isCorrect: true,
          message: 'Success!',
          reactionType: aiResult['type']?.toString() ?? 'addition',
          explanation: _aiExplanation,
          product: DynamicProduct(
            name: pName,
            formula: _pubChemData!.molecularFormula,
          ),
        );
      } else {
        // AI එකෙන් "No Reaction" හෝ වෙනත් Error එකක් ආවොත්
        _aiExplanation =
            aiResult?['explanation']?.toString() ??
            "No organic reaction occurs under these conditions.";
        _lastResult = ReactionResult(
          isCorrect: false,
          message: 'No Reaction',
          hintMessage: _aiExplanation,
          explanation: _aiExplanation,
        );
      }
    } catch (e) {
      debugPrint('🚨 Dynamic Reaction Error: $e');
      _lastResult = ReactionResult.failure(
        'Failed to process reaction. Please try again!',
      );
    } finally {
      _isEnriching = false;
      notifyListeners();
    }
  }

  /// Resets the practice lab selections.
  void resetPractice() {
    _selectedReactantA = null;
    _selectedReactantB = null;
    _selectedCondition = null;
    _lastResult = null;
    _aiExplanation = null;
    _pubChemData = null;
    _isEnriching = false;
    notifyListeners();
  }

  // ── Tutor Chat ────────────────────────────────────────────

  /// Sends a question to the AI tutor and appends the response.
  Future<void> askTutor(String question) async {
    if (question.trim().isEmpty) return;

    _tutorMessages.add(TutorMessage(text: question, isUser: true));
    _isTutorTyping = true;
    notifyListeners();

    try {
      final response = await _aiService.askTutor(question);
      _tutorMessages.add(
        TutorMessage(
          text: response ?? 'Sorry, I couldn\'t process that. Try again!',
          isUser: false,
        ),
      );
    } catch (e) {
      _tutorMessages.add(
        TutorMessage(
          text: 'Oops! Something went wrong. Please try again.',
          isUser: false,
        ),
      );
    } finally {
      _isTutorTyping = false;
      notifyListeners();
    }
  }

  /// Resets the tutor chat history.
  void clearTutorChat() {
    _tutorMessages.clear();
    _aiService.resetTutorChat();
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────

  /// Look up a compound by ID.
  Compound? compoundById(String id) {
    try {
      return _compounds.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
