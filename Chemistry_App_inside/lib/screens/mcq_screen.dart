import 'package:chemistry_app/l10n/app_localizations.dart';
import 'package:chemistry_app/providers/chemistry_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mcq_model.dart';
import '../services/ai_service.dart';
import '../services/scoring_service.dart';

class QuizScreen extends StatefulWidget {
  final PastPaperYear paper;
  final AiService aiService;

  const QuizScreen({super.key, required this.paper, required this.aiService});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final Map<int, String> _selectedAnswers = {};
  final Map<int, String> _explanations = {};
  final Map<int, bool> _isLoading = {};
  final Map<int, bool> _isCorrect = {};

  int _score = 0;
  bool _quizCompleted = false;

  Future<void> _submitAnswer(
    int questionIndex,
    String selectedOption,
    McqQuestion q,
  ) async {
    if (_selectedAnswers.containsKey(questionIndex)) return;

    final isCorrect = selectedOption == q.correctAnswer;

    setState(() {
      _selectedAnswers[questionIndex] = selectedOption;
      _isCorrect[questionIndex] = isCorrect;
      _isLoading[questionIndex] = true;

      if (isCorrect) {
        _score += 10; // 10 points per correct answer
      }
    });

    final l10n = AppLocalizations.of(context)!;
    final isSinhala = Localizations.localeOf(context).languageCode == 'si';

    // Get AI explanation
    final explanation = await widget.aiService.getMcqExplanation(
      q.getQuestion(context),
      q.getOptions(context).toString(),
      q.correctAnswer,
      selectedOption,
      isSinhala,
    );

    // Add points to global score using scoring service
    if (isCorrect) {
      final scoringService = ScoringService();
      await scoringService.addPoints(
        context,
        mode: GameMode.lessons,
        action: 'quiz_correct',
        customPoints: 10,
        customReason: 'Correct answer in ${widget.paper.year} quiz',
      );

      // Update chemistry provider
      final chemistryProvider = Provider.of<ChemistryProvider>(
        context,
        listen: false,
      );
      chemistryProvider.incrementCorrectAttempts();
      chemistryProvider.incrementTotalAttempts();
    } else {
      final chemistryProvider = Provider.of<ChemistryProvider>(
        context,
        listen: false,
      );
      chemistryProvider.incrementTotalAttempts();
    }

    setState(() {
      _explanations[questionIndex] = explanation ?? l10n.explanationError;
      _isLoading[questionIndex] = false;
    });
  }

  void _showResultDialog() {
    final l10n = AppLocalizations.of(context)!;
    final totalQuestions = widget.paper.questions.length;
    final percentage = (_score / (totalQuestions * 10)) * 100;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(
          children: [
            Icon(
              percentage >= 70 ? Icons.emoji_events : Icons.school,
              color: percentage >= 70 ? Colors.amber : Colors.cyan,
            ),
            const SizedBox(width: 10),
            Text(
              percentage >= 70 ? l10n.excellent : l10n.quizCompleted,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.yourScore}: $_score / ${totalQuestions * 10}',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.percentage}: ${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: percentage >= 70 ? Colors.green : Colors.orange,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.correctAnswers}: ${_isCorrect.values.where((v) => v == true).length} / $totalQuestions',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          if (percentage >= 70)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Award bonus points
                _awardBonusPoints(percentage);
              },
              child: Text(
                l10n.claimBonus,
                style: const TextStyle(color: Colors.amber),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _awardBonusPoints(double percentage) async {
    final scoringService = ScoringService();
    int bonusPoints = 0;

    if (percentage >= 90) {
      bonusPoints = 50;
    } else if (percentage >= 80) {
      bonusPoints = 30;
    } else if (percentage >= 70) {
      bonusPoints = 20;
    }

    if (bonusPoints > 0) {
      await scoringService.addPoints(
        context,
        mode: GameMode.lessons,
        action: 'perfect_score',
        customPoints: bonusPoints,
        customReason: 'Excellent performance in ${widget.paper.year} quiz!',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Bonus $bonusPoints points awarded!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalQuestions = widget.paper.questions.length;
    final answeredCount = _selectedAnswers.length;
    final isQuizComplete = answeredCount == totalQuestions && !_quizCompleted;

    if (isQuizComplete) {
      _quizCompleted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResultDialog();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(
          '${widget.paper.year} ${l10n.mcqQuiz}',
          style: const TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.quiz, color: Colors.cyan, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$answeredCount / $totalQuestions',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView.builder(
        itemCount: totalQuestions,
        itemBuilder: (context, index) {
          final q = widget.paper.questions[index];
          final isAnswered = _selectedAnswers.containsKey(index);
          final selectedAnswer = _selectedAnswers[index];
          final isCorrect = _isCorrect[index] ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.questionNumber(index + 1, totalQuestions),
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        q.getQuestion(context),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                const Text(
                  'Options',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ...q.getOptions(context).asMap().entries.map((entry) {
                  final optIndex = entry.key;
                  final opt = entry.value;
                  final isSelected = selectedAnswer == opt;

                  Color? cardColor;
                  if (isAnswered) {
                    if (opt == q.correctAnswer) {
                      cardColor = Colors.green.shade800;
                    } else if (isSelected) {
                      cardColor = Colors.red.shade800;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: cardColor ?? const Color(0xFF1E293B),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAnswered && opt == q.correctAnswer
                              ? Colors.green
                              : (isSelected && isAnswered
                                    ? Colors.red
                                    : Colors.grey.shade700),
                          radius: 14,
                          child: Text(
                            String.fromCharCode(65 + optIndex),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(
                          opt,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: isAnswered && opt == q.correctAnswer
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : (isSelected &&
                                      isAnswered &&
                                      opt != q.correctAnswer
                                  ? const Icon(Icons.cancel, color: Colors.red)
                                  : null),
                        onTap: isAnswered
                            ? null
                            : () => _submitAnswer(index, opt, q),
                      ),
                    ),
                  );
                }),

                // Loading indicator
                if (_isLoading[index] == true)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // Explanation
                if (_explanations.containsKey(index))
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCorrect
                            ? [Colors.green.shade900, Colors.green.shade800]
                            : [Colors.orange.shade900, Colors.orange.shade800],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.thumb_up : Icons.psychology,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCorrect ? l10n.correct : l10n.incorrect,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _explanations[index]!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
