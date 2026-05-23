import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/lesson.dart';
import '../providers/chemistry_provider.dart';
import 'lesson_detail_screen.dart';

/// Displays the list of available lessons as stylish cards.
class LessonListScreen extends StatelessWidget {
  const LessonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lessons')),
      body: Consumer<ChemistryProvider>(
        builder: (context, provider, _) {
          if (provider.lessons.isEmpty) {
            return const Center(
              child: Text(
                'No lessons available yet.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.lessons.length,
            itemBuilder: (context, index) {
              final lesson = provider.lessons[index];
              final isCompleted = provider.isLessonCompleted(lesson.id);
              return _LessonCard(
                lesson: lesson,
                index: index,
                isCompleted: isCompleted,
              );
            },
          );
        },
      ),
    );
  }
}

/// A single lesson card with gradient accent and completion state.
class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool isCompleted;

  const _LessonCard({
    required this.lesson,
    required this.index,
    required this.isCompleted,
  });

  static const _accentColors = [
    Color(0xFF00897B),
    Color(0xFF7C3AED),
    Color(0xFFEF6C00),
    Color(0xFF1E88E5),
    Color(0xFFD81B60),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accentColors[index % _accentColors.length];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonDetailScreen(lesson: lesson),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppTheme.accentGreen.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 6,
              height: 90,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 18),
            // Lesson number circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Title & level
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${lesson.level} · ${lesson.relatedReactions.length} reactions',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Completion indicator
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: isCompleted
                  ? const Icon(Icons.check_circle,
                      color: AppTheme.accentGreen, size: 24)
                  : Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.3), size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
