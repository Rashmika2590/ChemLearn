// [LessonScreen.dart - සම්පූර්ණ කෝඩ් එක]
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/lesson_model.dart';
import '../providers/lesson_provider.dart';
import '../providers/chemistry_provider.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonProvider>(
      builder: (context, lp, _) {
        final lesson = lp.currentLesson;
        if (lesson == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final slides = lesson.body
            .get(lp.currentLocale)
            .split('\n\n')
            .where((s) => s.trim().isNotEmpty)
            .toList();
        final totalPages = slides.length + lesson.quizzes.length;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              lesson.title.get(lp.currentLocale),
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              // ලකුණු (Global Score) මෙතැනදී Live පෙන්වයි
              Consumer<ChemistryProvider>(
                builder: (context, chem, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "${chem.totalPoints}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: LinearProgressIndicator(
                  value: (_currentPageIndex + 1) / totalPages,
                  backgroundColor: Colors.white10,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: totalPages,
                  onPageChanged: (i) => setState(() => _currentPageIndex = i),
                  itemBuilder: (context, i) => i < slides.length
                      ? _buildContent(slides[i])
                      : _buildQuiz(lesson.quizzes[i - slides.length], lp),
                ),
              ),
              _buildBottomBar(totalPages, slides.length, lp),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(String text) => Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppTheme.cardDark, Colors.blueGrey.shade900],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white10),
    ),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white70,
          height: 1.5,
        ),
      ),
    ),
  );

  Widget _buildQuiz(LessonQuiz quiz, LessonProvider lp) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        quiz.question.get(lp.currentLocale),
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Points: ${quiz.points}",
          style: const TextStyle(color: Colors.amber),
        ),
      ),
      const SizedBox(height: 20),
      ...List.generate(quiz.options.length, (i) {
        bool isSelected = lp.selectedAnswerIndex == i;
        bool isCorrect = i == quiz.correctOptionIndex;
        Color color = lp.isAnswerSubmitted
            ? (isCorrect
                  ? Colors.green.withAlpha(128)
                  : (isSelected ? Colors.red.withAlpha(102) : Colors.white10))
            : (isSelected ? Colors.blue.withAlpha(77) : Colors.white10);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            title: Text(quiz.options[i].get(lp.currentLocale)),
            onTap: lp.isAnswerSubmitted ? null : () => lp.selectAnswer(i),
          ),
        );
      }),
      if (lp.isAnswerSubmitted && lp.hasMastered)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber),
              SizedBox(width: 10),
              Text("Awesome! Mastered!", style: TextStyle(color: Colors.amber)),
            ],
          ),
        ),
    ],
  );

  Widget _buildBottomBar(int total, int slidesCount, LessonProvider lp) {
    bool isQuiz = _currentPageIndex >= slidesCount;
    String btnText = !isQuiz
        ? "Next"
        : (lp.isAnswerSubmitted
              ? (_currentPageIndex == total - 1 ? "Finish" : "Next Question")
              : "Submit");

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          if (!isQuiz) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          } else if (!lp.isAnswerSubmitted) {
            // Submit කරනකොට ලකුණු එකතු වෙයි
            if (lp.submitAnswer()) {
              Provider.of<ChemistryProvider>(
                context,
                listen: false,
              ).addPoints(lp.currentQuiz!.points);
            }
          } else {
            // Next question හෝ Finish
            if (lp.nextQuestion()) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            } else {
              Provider.of<ChemistryProvider>(
                context,
                listen: false,
              ).markLessonCompleted(lp.currentLesson!.id);
              Navigator.pop(context);
            }
          }
        },
        child: Text(btnText),
      ),
    );
  }
}
