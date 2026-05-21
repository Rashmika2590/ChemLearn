import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/chemistry_provider.dart';
import 'lesson_list_screen.dart';
import 'practice_screen.dart';
import 'tutor_screen.dart';

/// The main landing screen of the app.
///
/// Shows a welcome header, the user's score, and navigation cards
/// for Lessons and Practice Lab.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ChemistryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading chemistry data…'),
                  ],
                ),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: AppTheme.errorRed),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.errorRed),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => provider.initialize(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────
                  _buildHeader(context, provider),
                  const SizedBox(height: 32),

                  // ── Score Card ──────────────────────────────
                  _buildScoreCard(context, provider),
                  const SizedBox(height: 28),

                  // ── Quick Stats ─────────────────────────────
                  _buildQuickStats(provider),
                  const SizedBox(height: 28),

                  // ── Navigation Cards ────────────────────────
                  Text(
                    'Start Learning',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildNavCard(
                    context,
                    icon: Icons.menu_book_rounded,
                    title: 'Lessons',
                    subtitle:
                        '${provider.lessons.length} topics · ${provider.completedLessonIds.length} completed',
                    gradient: AppTheme.primaryGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LessonListScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNavCard(
                    context,
                    icon: Icons.science_rounded,
                    title: 'Practice Lab',
                    subtitle: 'Mix reactants & discover products',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PracticeScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNavCard(
                    context,
                    icon: Icons.psychology_rounded,
                    title: 'Chemistry Tutor',
                    subtitle: 'AI-powered Q&A for organic chemistry',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF6C00), Color(0xFFFFA726)],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TutorScreen()),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header with app name ──────────────────────────────────
  Widget _buildHeader(BuildContext context, ChemistryProvider provider) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.biotech_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ChemLearn',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
            Text(
              'Master Organic Chemistry',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Score Card ────────────────────────────────────────────
  Widget _buildScoreCard(BuildContext context, ChemistryProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const Text(
            'Your Score',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: provider.score),
            duration: const Duration(milliseconds: 600),
            builder: (_, value, __) => Text(
              '$value',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Color(0xFF00E5FF),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'points',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Stats Row ───────────────────────────────────────
  Widget _buildQuickStats(ChemistryProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _statTile(
            icon: Icons.check_circle_outline,
            value: '${provider.correctAttempts}',
            label: 'Correct',
            color: AppTheme.accentGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            icon: Icons.repeat_rounded,
            value: '${provider.totalAttempts}',
            label: 'Attempts',
            color: AppTheme.accentOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            icon: Icons.book_outlined,
            value:
                '${provider.completedLessonIds.length}/${provider.lessons.length}',
            label: 'Lessons',
            color: const Color(0xFF42A5F5),
          ),
        ),
      ],
    );
  }

  Widget _statTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  // ── Navigation Card ───────────────────────────────────────
  Widget _buildNavCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.7), size: 18),
          ],
        ),
      ),
    );
  }
}
