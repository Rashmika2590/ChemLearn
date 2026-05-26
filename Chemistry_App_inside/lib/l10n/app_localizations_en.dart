// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ChemLearn';

  @override
  String get appSubtitle => 'Master Organic Chemistry';

  @override
  String get loadingData => 'Loading chemistry data…';

  @override
  String get retry => 'Retry';

  @override
  String get yourScore => 'Your Score';

  @override
  String get points => 'points';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Inorrect';

  @override
  String get attempts => 'Attempts';

  @override
  String get lessons => 'Lessons';

  @override
  String get startLearning => 'Start Learning';

  @override
  String lessonsSubtitle(int count, int completed) {
    return '$count topics · $completed completed';
  }

  @override
  String get practiceLab => 'Practice Lab';

  @override
  String get practiceLabSubtitle => 'Mix reactants & discover products';

  @override
  String get chemistryTutor => 'Organic Chemistry Tutor';

  @override
  String get chemistryTutorSubtitle => 'AI-powered Q&A for organic chemistry';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get noLessons => 'No lessons available yet.';

  @override
  String level(int level) {
    return 'Level $level';
  }

  @override
  String reactionsCount(int count) {
    return '$count reactions';
  }

  @override
  String get reactantA => 'Reactant A';

  @override
  String get reactantB => 'Reactant B (optional)';

  @override
  String get reactionCondition => 'Reaction Condition';

  @override
  String get selectCondition => 'Select condition';

  @override
  String get reactButton => 'React!';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get instructions =>
      'Search and select reactants, then tap \"React!\" to analyze.';

  @override
  String get aiFormulating => 'AI is formulating response...';

  @override
  String get pubChemData => 'PubChem Data';

  @override
  String get iupacName => 'IUPAC Name';

  @override
  String get formula => 'Formula';

  @override
  String get molecularWeight => 'Molecular Weight';

  @override
  String get reactionOccurred => 'Reaction Occurred!';

  @override
  String get noReaction => 'No Reaction';

  @override
  String productName(String name) {
    return 'Product: $name';
  }

  @override
  String get clearChat => 'Clear chat';

  @override
  String get aiTutorUnavailable => 'AI Tutor Unavailable';

  @override
  String get aiTutorRequiresKey => 'The AI tutor requires a Gemini API key.';

  @override
  String get askAnything => 'Ask me anything about\nOrganic Chemistry!';

  @override
  String get iCanExplain =>
      'I can explain reactions, concepts,\nand help you understand chemistry better.';

  @override
  String get thinking => 'Thinking…';

  @override
  String get askAQuestion => 'Ask a chemistry question…';

  @override
  String get conversionMaster => 'Conversion Master';

  @override
  String get conversionSubtitle => 'Master your organic reactions step-by-step';

  @override
  String get conversions => 'conversions';

  @override
  String get start => 'START';

  @override
  String get current => 'CURRENT';

  @override
  String get target => 'TARGET';

  @override
  String get gameOver => 'Game Over!';

  @override
  String scoreRestart(int score) {
    return 'Score: $score. Restart the challenge?';
  }

  @override
  String get restart => 'Restart';

  @override
  String get playAgain => 'PLAY AGAIN';

  @override
  String get searchReagents => 'Search reagents...';

  @override
  String newChallenge(String start, String target) {
    return 'New Challenge: Transform $start to $target!';
  }

  @override
  String get excellentLevelComplete => 'Excellent! Level Complete.';

  @override
  String get correctKeepGoing => 'Correct! Keep going.';

  @override
  String get incorrectTryAgain => 'Incorrect! Try another reagent.';

  @override
  String get nextLevel => 'Next Level';

  @override
  String get exit => 'Exit';

  @override
  String get yourScoreLabel => 'Your Score';

  @override
  String get totalScore => 'Total Score';

  @override
  String get stepsCompleted => 'Steps Completed';

  @override
  String get newChallengeButton => 'New Challenge';

  @override
  String get pastPaperChallenge => 'Past Paper Challenge';

  @override
  String get pastPaperSubtitle => '2000-2025 Organic MCQs';

  @override
  String get mcqQuiz => 'MCQ Quiz';

  @override
  String questionNumber(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get explanationError => 'Unable to fetch explanation.';

  @override
  String get excellent => 'Excellent!';

  @override
  String get quizCompleted => 'Quiz Completed!';

  @override
  String get percentage => 'Percentage';

  @override
  String get correctAnswers => 'Correct Answers';

  @override
  String get close => 'Close';

  @override
  String get claimBonus => 'Claim Bonus';

  @override
  String get pastPapers => 'Past Papers (2000-2025)';

  @override
  String chemistryYear(int year) {
    return '$year A/L ';
  }

  @override
  String get questionsNotAvailable =>
      'Questions for this year are not yet available.';
}
