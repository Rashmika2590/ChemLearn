import 'package:chemistry_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/lesson_model.dart';
import '../providers/chemistry_provider.dart';
import '../providers/lesson_provider.dart';
import 'lesson_screen.dart';

/// Displays the list of available localized lessons loaded from local JSON assets.
class LessonListScreen extends StatelessWidget {
  const LessonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.lessons)),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, _) {
          if (lessonProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (lessonProvider.lessons.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noLessons,
                style: const TextStyle(color: Colors.white54),
              ),
            );
          }

          // We read completion status from the ChemistryProvider
          final chemistryProvider = context.watch<ChemistryProvider>();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: lessonProvider.lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessonProvider.lessons[index];
              final isCompleted = chemistryProvider.isLessonCompleted(lesson.id);
              return _LessonCard(
                lesson: lesson,
                index: index,
                isCompleted: isCompleted,
                currentLocale: lessonProvider.currentLocale,
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
  final String currentLocale;

  const _LessonCard({
    required this.lesson,
    required this.index,
    required this.isCompleted,
    required this.currentLocale,
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
    final titleText = lesson.title.get(currentLocale);

    return GestureDetector(
      onTap: () {
        final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
        lessonProvider.setLessonIndex(index);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LessonScreen()),
        );
      },
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
                      titleText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context)!.level(lesson.level)} · ${AppLocalizations.of(context)!.reactionsCount(lesson.relatedReactions.length)}',
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
                  ? const Icon(
                      Icons.check_circle,
                      color: AppTheme.accentGreen,
                      size: 24,
                    )
                  : Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 16,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
