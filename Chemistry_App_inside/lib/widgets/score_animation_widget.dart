import 'dart:math';
import 'package:flutter/material.dart';
import '../services/scoring_service.dart';

class ScoreAnimationWidget extends StatefulWidget {
  final Widget child;
  final GameMode gameMode;

  const ScoreAnimationWidget({
    super.key,
    required this.child,
    required this.gameMode,
  });

  @override
  State<ScoreAnimationWidget> createState() => _ScoreAnimationWidgetState();
}

class _ScoreAnimationWidgetState extends State<ScoreAnimationWidget>
    with SingleTickerProviderStateMixin {
  final ScoringService _scoringService = ScoringService();
  final List<FloatingPoint> _floatingPoints = [];

  @override
  void initState() {
    super.initState();
    _scoringService.onPointsAdded = _onPointsAdded;
    _scoringService.onStreakUpdated = _onStreakUpdated;
  }

  void _onPointsAdded(GameMode mode, int points, String reason) {
    if (mode == widget.gameMode) {
      setState(() {
        _floatingPoints.add(
          FloatingPoint(
            id: DateTime.now().millisecondsSinceEpoch,
            points: points,
            reason: reason,
            position: Offset(
              Random().nextDouble() * 200 - 100,
              Random().nextDouble() * 100,
            ),
          ),
        );
      });

      // Remove after animation
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _floatingPoints.removeWhere((fp) => fp.id == _floatingPoints.last.id);
        });
      });
    }
  }

  void _onStreakUpdated(GameMode mode, int streak) {
    if (mode == widget.gameMode && streak >= 3) {
      // Show streak notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange),
              const SizedBox(width: 8),
              Text('🔥 $streak Streak! Keep going!'),
            ],
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.orange.shade900,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._floatingPoints.map((fp) => _buildFloatingPoint(fp)),
      ],
    );
  }

  Widget _buildFloatingPoint(FloatingPoint fp) {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 + fp.position.dx,
      top: MediaQuery.of(context).size.height / 2 + fp.position.dy,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: -100),
        duration: const Duration(milliseconds: 1000),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: Opacity(
              opacity: 1 - (value / -100).clamp(0, 1),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                '+${fp.points}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (fp.reason.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  fp.reason,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scoringService.onPointsAdded = null;
    _scoringService.onStreakUpdated = null;
    super.dispose();
  }
}

class FloatingPoint {
  final int id;
  final int points;
  final String reason;
  final Offset position;

  FloatingPoint({
    required this.id,
    required this.points,
    required this.reason,
    required this.position,
  });
}
