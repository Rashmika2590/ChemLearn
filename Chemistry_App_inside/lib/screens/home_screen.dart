import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/chemistry_provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/locale_provider.dart';
import 'lesson_list_screen.dart';
import 'practice_screen.dart';
import 'tutor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Consumer2 මගින් Provider දෙකම එකට monitor කරනවා
        child: Consumer2<ChemistryProvider, LessonProvider>(
          builder: (context, chem, lesson, _) {
            if (chem.isLoading || lesson.isLoading) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.loadingData),
                  ],
                ),
              );
            }

            final l10n = AppLocalizations.of(context)!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, chem),
                  const SizedBox(height: 32),
                  _buildScoreCard(context, chem),
                  const SizedBox(height: 28),
                  _buildQuickStats(context, chem, lesson),
                  const SizedBox(height: 28),

                  Text(
                    l10n.startLearning,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lessons Card - මෙතන lesson provider එකේ length එක පාවිච්චි වෙනවා
                  _buildNavCard(
                    context,
                    icon: Icons.menu_book_rounded,
                    title: l10n.lessons,
                    subtitle: l10n.lessonsSubtitle(
                      lesson.lessons.length,
                      chem.completedLessonIds.length,
                    ),
                    gradient: AppTheme.primaryGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LessonListScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNavCard(
                    context,
                    icon: Icons.science_rounded,
                    title: l10n.practiceLab,
                    subtitle: l10n.practiceLabSubtitle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PracticeScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNavCard(
                    context,
                    icon: Icons.psychology_rounded,
                    title: l10n.chemistryTutor,
                    subtitle: l10n.chemistryTutorSubtitle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF6C00), Color(0xFFFFA726)],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TutorScreen()),
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
          child: const Icon(
            Icons.biotech_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
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
                AppLocalizations.of(context)!.appSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
        _buildLanguageToggle(context),
      ],
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isSinhala = localeProvider.locale?.languageCode == 'si';
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isSinhala ? 'EN' : 'සිං',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      onPressed: () => localeProvider.setLocale(
        isSinhala ? const Locale('en') : const Locale('si'),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, ChemistryProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.yourScore,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
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
          Text(
            AppLocalizations.of(context)!.points,
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    ChemistryProvider chem,
    LessonProvider lesson,
  ) {
    return Row(
      children: [
        Expanded(
          child: _statTile(
            icon: Icons.check_circle_outline,
            value: '${chem.correctAttempts}',
            label: AppLocalizations.of(context)!.correct,
            color: AppTheme.accentGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            icon: Icons.repeat_rounded,
            value: '${chem.totalAttempts}',
            label: AppLocalizations.of(context)!.attempts,
            color: AppTheme.accentOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statTile(
            icon: Icons.book_outlined,
            value: '${chem.completedLessonIds.length}/${lesson.lessons.length}',
            label: AppLocalizations.of(context)!.lessons,
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
        //border: Border.all(color: Colors.white),
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
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white38),
          ),
        ],
      ),
    );
  }

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
              color: Colors.black26,
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
                color: Colors.white24,
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
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
