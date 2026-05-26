import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chemistry_provider.dart';

/// Different game modes in the app
enum GameMode { lessons, practice, conversion, tutor }

/// Scoring service to manage points across all game modes
class ScoringService {
  // Singleton pattern
  static final ScoringService _instance = ScoringService._internal();
  factory ScoringService() => _instance;
  ScoringService._internal();

  // Point values for different actions
  static const Map<GameMode, Map<String, int>> pointValues = {
    GameMode.conversion: {
      'correct_step': 10,
      'level_complete': 50,
      'perfect_level': 100,
      'streak_bonus_3': 15,
      'streak_bonus_5': 25,
      'streak_bonus_10': 50,
    },
    GameMode.practice: {
      'correct_reaction': 20,
      'streak_3': 15,
      'streak_5': 25,
      'streak_10': 50,
      'first_time_correct': 10,
    },
    GameMode.lessons: {
      'lesson_complete': 100,
      'quiz_correct': 20,
      'section_complete': 50,
      'perfect_score': 150,
    },
    GameMode.tutor: {
      'question_asked': 2,
      'helpful_response': 5,
      'streak_questions': 10,
    },
  };

  // Track streaks per game mode
  final Map<GameMode, int> _streaks = {};
  final Map<GameMode, DateTime?> _lastActionTime = {};

  // Track if it's first time for certain actions
  final Map<String, Set<String>> _completedActions = {};

  // Event callback for point additions (for animations/notifications)
  Function(GameMode mode, int points, String reason)? onPointsAdded;
  Function(GameMode mode, int points, String reason)? onPointsDeducted;
  Function(GameMode mode, int streakCount)? onStreakUpdated;

  /// Add points for an action
  Future<void> addPoints(
    BuildContext context, {
    required GameMode mode,
    required String action,
    int? customPoints,
    String? customReason,
    bool updateStreak = true,
  }) async {
    final chemistryProvider = Provider.of<ChemistryProvider>(
      context,
      listen: false,
    );

    int points = customPoints ?? pointValues[mode]?[action] ?? 0;

    if (points <= 0) return;

    // Update streak if enabled
    if (updateStreak) {
      await _updateStreak(mode, context);
      if (!context.mounted) return;
      // Check for streak bonuses
      final streakBonus = await _checkStreakBonus(mode, context);
      if (streakBonus > 0) {
        points += streakBonus;
        _notifyPointsAdded(mode, streakBonus, '🔥 Streak Bonus!');
      }
    }

    // Check for first-time completion bonus
    // 1. මුලින්ම await කරලා bonus එක ගන්නවා
    final firstTimeBonus = await _checkFirstTimeBonus(mode, action, context);

    // 2. අනිවාර්යයෙන්ම මේ check එක කරන්න!
    if (!context.mounted) return;

    // 3. දැන් Points update කරන logic එක තියන්න
    if (firstTimeBonus > 0) {
      points += firstTimeBonus;
      _notifyPointsAdded(mode, firstTimeBonus, '🎉 First Time Bonus!');
    }
    // මේ පේළිය අනිවාර්යයි
    if (!context.mounted) return;

    if (firstTimeBonus > 0) {
      points += firstTimeBonus;
      _notifyPointsAdded(mode, firstTimeBonus, '🎉 First Time Bonus!');
    }
    // Add points using ChemistryProvider's method
    chemistryProvider.addPoints(points);

    // Notify listeners with reason
    final reason = customReason ?? '${mode.name.toUpperCase()} - $action';
    _notifyPointsAdded(mode, points, reason);

    // Optional: Save to database or analytics
    await _logPointEvent(mode, action, points, true);

    return;
  }

  /// Deduct points as penalty
  Future<void> deductPoints(
    BuildContext context, {
    required GameMode mode,
    required String reason,
    int points = 5,
    String? customReason,
  }) async {
    final chemistryProvider = Provider.of<ChemistryProvider>(
      context,
      listen: false,
    );

    // Reset streak when penalty applied
    _streaks[mode] = 0;
    onStreakUpdated?.call(mode, 0);

    // Deduct points
    chemistryProvider.deductPoints(points);

    final deductReason = customReason ?? reason;
    _notifyPointsDeducted(mode, points, deductReason);

    await _logPointEvent(mode, reason, points, false);

    return;
  }

  /// Update streak for a game mode
  Future<void> _updateStreak(GameMode mode, BuildContext context) async {
    final now = DateTime.now();
    final lastAction = _lastActionTime[mode];

    if (lastAction == null) {
      _streaks[mode] = 1;
    } else {
      final difference = now.difference(lastAction);
      // If last action was within 30 seconds, increment streak
      if (difference.inSeconds <= 30) {
        _streaks[mode] = (_streaks[mode] ?? 0) + 1;
      } else {
        // Streak broken
        if ((_streaks[mode] ?? 0) >= 3) {
          debugPrint('⚠️ Streak of ${_streaks[mode]} broken for $mode');
        }
        _streaks[mode] = 1;
      }
    }

    _lastActionTime[mode] = now;
    onStreakUpdated?.call(mode, _streaks[mode] ?? 0);
  }

  /// Check for streak bonuses
  Future<int> _checkStreakBonus(GameMode mode, BuildContext context) async {
    final streak = _streaks[mode] ?? 0;

    if (streak == 3) {
      return pointValues[mode]?['streak_bonus_3'] ?? 15;
    } else if (streak == 5) {
      return pointValues[mode]?['streak_bonus_5'] ?? 25;
    } else if (streak == 10) {
      return pointValues[mode]?['streak_bonus_10'] ?? 50;
    }

    return 0;
  }

  /// Check for first-time completion bonus
  Future<int> _checkFirstTimeBonus(
    GameMode mode,
    String action,
    BuildContext context,
  ) async {
    final key = '${mode.name}_$action';

    if (!_completedActions.containsKey(key)) {
      _completedActions[key] = {};
    }

    if (!_completedActions[key]!.contains('completed')) {
      _completedActions[key]!.add('completed');

      // Return first-time bonus if applicable
      if (mode == GameMode.conversion && action == 'level_complete') {
        return 25;
      } else if (mode == GameMode.practice && action == 'correct_reaction') {
        return 10;
      }
    }

    return 0;
  }

  /// Get current streak for a game mode
  int getStreak(GameMode mode) {
    return _streaks[mode] ?? 0;
  }

  /// Reset streak for a game mode
  void resetStreak(GameMode mode) {
    _streaks[mode] = 0;
    _lastActionTime[mode] = null;
    onStreakUpdated?.call(mode, 0);
  }

  /// Reset all streaks
  void resetAllStreaks() {
    _streaks.clear();
    _lastActionTime.clear();
    for (var mode in GameMode.values) {
      onStreakUpdated?.call(mode, 0);
    }
  }

  /// Get point value for an action
  static int getPointValue(GameMode mode, String action) {
    return pointValues[mode]?[action] ?? 0;
  }

  /// Get all point values for display
  static Map<String, dynamic> getPointValuesMap() {
    final map = <String, dynamic>{};
    for (var mode in GameMode.values) {
      map[mode.name] = pointValues[mode];
    }
    return map;
  }

  // Private helper methods
  void _notifyPointsAdded(GameMode mode, int points, String reason) {
    debugPrint('🎯 +$points points from ${mode.name} - $reason');
    onPointsAdded?.call(mode, points, reason);
  }

  void _notifyPointsDeducted(GameMode mode, int points, String reason) {
    debugPrint('⚠️ -$points points from ${mode.name} - $reason');
    onPointsDeducted?.call(mode, points, reason);
  }

  Future<void> _logPointEvent(
    GameMode mode,
    String action,
    int points,
    bool isAdd,
  ) async {
    // TODO: Save to analytics or database
    // Example: await FirebaseAnalytics.instance.logEvent(
    //   name: 'point_event',
    //   parameters: {
    //     'mode': mode.name,
    //     'action': action,
    //     'points': points,
    //     'type': isAdd ? 'add' : 'deduct',
    //   },
    // );
  }
}
