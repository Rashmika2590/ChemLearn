import 'dart:async';
import 'package:chemistry_app/data/reaction_data.dart';
import 'package:chemistry_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chemistry_provider.dart';
import '../services/scoring_service.dart';

class ConversionProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> levelLibrary = reactionLibrary;
  Timer? _feedbackTimer;
  BuildContext? _context;

  Map<String, Map<String, String>> currentFlow = {};
  String? startingMaterial;
  String? targetProduct;
  String? currentIntermediate;

  int lives = 5;
  int localScore = 0;
  List<String> steps = [];
  String? feedbackMessage;

  bool _levelCompleted = false;
  int _currentStreak = 0;

  void setContext(BuildContext context) {
    _context = context;
  }

  void nextLevel() {
    final level = (levelLibrary..shuffle()).first;
    startingMaterial = level['start'];
    targetProduct = level['target'];
    currentFlow = Map<String, Map<String, String>>.from(level['flow']);
    currentIntermediate = startingMaterial;
    lives = 5;
    localScore = 0;
    steps.clear();
    _levelCompleted = false;
    _currentStreak = 0;

    final l10n = AppLocalizations.of(_context!);
    feedbackMessage =
        l10n?.newChallenge(startingMaterial!, targetProduct!) ??
        "New Challenge: Transform $startingMaterial to $targetProduct!";

    notifyListeners();
  }

  void validateStep(String reagent) async {
    if (lives <= 0 || currentIntermediate == targetProduct) return;

    final possible = currentFlow[currentIntermediate];
    _feedbackTimer?.cancel();

    final l10n = AppLocalizations.of(_context!);
    final scoringService = ScoringService();

    if (possible != null && possible.containsKey(reagent)) {
      // Correct step
      currentIntermediate = possible[reagent];
      steps.add("$reagent ➡️ $currentIntermediate");
      localScore += 10;
      _currentStreak++;

      // Add points via scoring service
      if (_context != null) {
        await scoringService.addPoints(
          _context!,
          mode: GameMode.conversion,
          action: 'correct_step',
          customPoints: 10,
          customReason: 'Correct conversion step',
          updateStreak: true,
        );

        // Update ChemistryProvider attempts
        final chemistryProvider = Provider.of<ChemistryProvider>(
          _context!,
          listen: false,
        );
        chemistryProvider.incrementTotalAttempts();
        chemistryProvider.incrementCorrectAttempts();
      }

      if (currentIntermediate == targetProduct && !_levelCompleted) {
        _levelCompleted = true;

        // Level completion bonus
        const levelBonus = 50;
        localScore += levelBonus;

        if (_context != null) {
          await scoringService.addPoints(
            _context!,
            mode: GameMode.conversion,
            action: 'level_complete',
            customPoints: levelBonus,
            customReason: '🎉 Level Complete!',
            updateStreak: false,
          );
        }

        // Perfect level bonus (no lives lost)
        if (lives == 5 && _context != null) {
          const perfectBonus = 100;
          localScore += perfectBonus;
          await scoringService.addPoints(
            _context!,
            mode: GameMode.conversion,
            action: 'perfect_level',
            customPoints: perfectBonus,
            customReason: '🏆 Perfect Level! No lives lost!',
            updateStreak: false,
          );
        }

        feedbackMessage =
            l10n?.excellentLevelComplete ?? "Excellent! Level Complete.";
      } else {
        feedbackMessage = l10n?.correctKeepGoing ?? "Correct! Keep going.";
      }
    } else {
      // Incorrect step
      _currentStreak = 0;
      lives--;

      if (_context != null) {
        // Reset streak in scoring service
        scoringService.resetStreak(GameMode.conversion);

        // Update attempts (incorrect)
        final chemistryProvider = Provider.of<ChemistryProvider>(
          _context!,
          listen: false,
        );
        chemistryProvider.incrementTotalAttempts();

        // Optional penalty for wrong answers (set to 0 for no penalty)
        await scoringService.deductPoints(
          _context!,
          mode: GameMode.conversion,
          reason: 'incorrect_step',
          points: 0,
        );
      }

      if (lives > 0) {
        feedbackMessage =
            l10n?.incorrectTryAgain ?? "Incorrect! Try another reagent.";
      } else {
        feedbackMessage = l10n?.gameOver ?? "Game Over!";
      }
    }

    notifyListeners();

    _feedbackTimer = Timer(const Duration(seconds: 10), () {
      feedbackMessage = null;
      notifyListeners();
    });
  }

  int getCurrentStreak() => _currentStreak;

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
