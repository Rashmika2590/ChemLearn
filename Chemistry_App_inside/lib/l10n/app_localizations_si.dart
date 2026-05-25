// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appTitle => 'ChemLearn';

  @override
  String get appSubtitle => 'කාබනික රසායන විද්‍යාව ප්‍රගුණ කරන්න';

  @override
  String get loadingData => 'රසායන විද්‍යා දත්ත පූරණය වෙමින්…';

  @override
  String get retry => 'නැවත උත්සාහ කරන්න';

  @override
  String get yourScore => 'ඔබේ ලකුණු';

  @override
  String get points => 'ලකුණු';

  @override
  String get correct => 'නිවැරදි';

  @override
  String get attempts => 'උත්සාහයන්';

  @override
  String get lessons => 'පාඩම්';

  @override
  String get startLearning => 'ඉගෙනීම ආරම්භ කරන්න';

  @override
  String lessonsSubtitle(int count, int completed) {
    return 'මාතෘකා $count · සම්පූර්ණ කළ $completed';
  }

  @override
  String get practiceLab => 'පුහුණු රසායනාගාරය';

  @override
  String get practiceLabSubtitle =>
      'ප්‍රතික්‍රියාකාරක මිශ්‍ර කර නිෂ්පාදන සොයා ගන්න';

  @override
  String get chemistryTutor => 'කාබනික රසායන විද්‍යා උපදේශකයා';

  @override
  String get chemistryTutorSubtitle => 'AI බලයෙන් ක්‍රියාත්මක ප්‍රශ්නෝත්තර';

  @override
  String get settings => 'සැකසුම්';

  @override
  String get language => 'භාෂාව';

  @override
  String get noLessons => 'තවමත් පාඩම් ලබා ගත නොහැක.';

  @override
  String level(int level) {
    return '$level මට්ටම';
  }

  @override
  String reactionsCount(int count) {
    return 'ප්‍රතික්‍රියා $count';
  }

  @override
  String get reactantA => 'ප්‍රතික්‍රියාකාරක A';

  @override
  String get reactantB => 'ප්‍රතික්‍රියාකාරක B (අත්‍යවශ්‍ය නොවේ)';

  @override
  String get reactionCondition => 'ප්‍රතික්‍රියා කොන්දේසි';

  @override
  String get selectCondition => 'කොන්දේසිය තෝරන්න';

  @override
  String get reactButton => 'ප්‍රතික්‍රියා කරවන්න!';

  @override
  String get analyzing => 'විශ්ලේෂණය කරමින්...';

  @override
  String get instructions =>
      'ප්‍රතික්‍රියාකාරක සොයාගෙන තෝරාගන්න, පසුව විශ්ලේෂණය කිරීමට \"ප්‍රතික්‍රියා කරවන්න!\" බොත්තම ඔබන්න.';

  @override
  String get aiFormulating => 'AI ප්‍රතිචාරයක් සකස් කරමින් පවතී...';

  @override
  String get pubChemData => 'PubChem දත්ත';

  @override
  String get iupacName => 'IUPAC නාමය';

  @override
  String get formula => 'සූත්‍රය';

  @override
  String get molecularWeight => 'අණුක ස්කන්ධය';

  @override
  String get reactionOccurred => 'ප්‍රතික්‍රියාව සිදු විය!';

  @override
  String get noReaction => 'ප්‍රතික්‍රියාවක් සිදු වූයේ නැත';

  @override
  String productName(String name) {
    return 'නිෂ්පාදනය: $name';
  }

  @override
  String get clearChat => 'චැට් එක මකන්න';

  @override
  String get aiTutorUnavailable => 'AI උපදේශකයා ලබා ගත නොහැක';

  @override
  String get aiTutorRequiresKey =>
      'AI උපදේශකයා සඳහා Gemini API යතුරක් අවශ්‍ය වේ.';

  @override
  String get askAnything =>
      'කාබනික රසායන විද්‍යාව ගැන ඔබට අවශ්‍ය ඕනෑම දෙයක් මාගෙන් අසන්න!';

  @override
  String get iCanExplain =>
      'මට ප්‍රතික්‍රියා, සංකල්ප පැහැදිලි කළ හැකි අතර රසායන විද්‍යාව වඩා හොඳින් අවබෝධ කර ගැනීමට ඔබට සහාය විය හැකිය.';

  @override
  String get thinking => 'සිතමින් පවතිනවා…';

  @override
  String get askAQuestion => 'රසායන විද්‍යාව පිළිබඳ ප්‍රශ්නයක් අසන්න…';

  @override
  String get conversionMaster => 'පරිවර්තන මාස්ටර්';

  @override
  String get conversionSubtitle =>
      'පියවරෙන් පියවර කාබනික ප්‍රතික්‍රියා ප්‍රගුණ කරන්න';

  @override
  String get conversions => 'පරිවර්තන';

  @override
  String get start => 'ආරම්භය';

  @override
  String get current => 'වර්තමානය';

  @override
  String get target => 'ඉලක්කය';

  @override
  String get gameOver => 'ක්‍රීඩාව අවසන්!';

  @override
  String scoreRestart(int score) {
    return 'ලකුණු: $score. නැවත අභියෝගය ආරම්භ කරන්න?';
  }

  @override
  String get restart => 'නැවත ආරම්භ කරන්න';

  @override
  String get playAgain => 'නැවත ක්‍රීඩා කරන්න';

  @override
  String get searchReagents => 'ප්‍රතික්‍රියාකාරක සොයන්න...';

  @override
  String newChallenge(String start, String target) {
    return 'නව අභියෝගය: $start සිට $target දක්වා පරිවර්තනය කරන්න!';
  }

  @override
  String get excellentLevelComplete => 'විශිෂ්ටයි! මට්ටම සම්පූර්ණයි.';

  @override
  String get correctKeepGoing => 'නිවැරදියි! ඉදිරියට යන්න.';

  @override
  String get incorrectTryAgain =>
      'වැරදියි! වෙනත් ප්‍රතික්‍රියාකාරකයක් උත්සාහ කරන්න.';

  @override
  String get nextLevel => 'ඊළඟ මට්ටම';

  @override
  String get exit => 'පිටවන්න';

  @override
  String get yourScoreLabel => 'ඔබේ ලකුණු';

  @override
  String get totalScore => 'සම්පූර්ණ ලකුණු';

  @override
  String get stepsCompleted => 'සම්පූර්ණ කළ පියවර';

  @override
  String get newChallengeButton => 'නව අභියෝගය';
}
