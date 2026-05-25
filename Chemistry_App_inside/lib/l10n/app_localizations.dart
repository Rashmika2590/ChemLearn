import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'ChemLearn'**
  String get appTitle;

  /// Tagline shown below the app title
  ///
  /// In en, this message translates to:
  /// **'Master Organic Chemistry'**
  String get appSubtitle;

  /// Shown while chemistry data is being fetched
  ///
  /// In en, this message translates to:
  /// **'Loading chemistry data…'**
  String get loadingData;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Score card heading
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// Label below the score number
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// Quick stats label – correct attempts
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// Quick stats label – total attempts
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get attempts;

  /// Navigation card title / stats label
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// Section heading above nav cards
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get startLearning;

  /// Subtitle for the Lessons navigation card
  ///
  /// In en, this message translates to:
  /// **'{count} topics · {completed} completed'**
  String lessonsSubtitle(int count, int completed);

  /// Navigation card title for Practice Lab
  ///
  /// In en, this message translates to:
  /// **'Practice Lab'**
  String get practiceLab;

  /// Subtitle for Practice Lab card
  ///
  /// In en, this message translates to:
  /// **'Mix reactants & discover products'**
  String get practiceLabSubtitle;

  /// Navigation card title for AI Tutor
  ///
  /// In en, this message translates to:
  /// **'Chemistry Tutor'**
  String get chemistryTutor;

  /// Subtitle for AI Tutor card
  ///
  /// In en, this message translates to:
  /// **'AI-powered Q&A for organic chemistry'**
  String get chemistryTutorSubtitle;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language selector label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Shown when the lesson list is empty
  ///
  /// In en, this message translates to:
  /// **'No lessons available yet.'**
  String get noLessons;

  /// Level indicator for lessons
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(int level);

  /// Number of reactions in a lesson
  ///
  /// In en, this message translates to:
  /// **'{count} reactions'**
  String reactionsCount(int count);

  /// Label for the first reactant
  ///
  /// In en, this message translates to:
  /// **'Reactant A'**
  String get reactantA;

  /// Label for the second reactant
  ///
  /// In en, this message translates to:
  /// **'Reactant B (optional)'**
  String get reactantB;

  /// Label for the reaction condition dropdown
  ///
  /// In en, this message translates to:
  /// **'Reaction Condition'**
  String get reactionCondition;

  /// Hint for the reaction condition dropdown
  ///
  /// In en, this message translates to:
  /// **'Select condition'**
  String get selectCondition;

  /// Button to trigger reaction check
  ///
  /// In en, this message translates to:
  /// **'React!'**
  String get reactButton;

  /// Shown during reaction analysis
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// App usage instructions
  ///
  /// In en, this message translates to:
  /// **'Search and select reactants, then tap \"React!\" to analyze.'**
  String get instructions;

  /// Loading text for AI response
  ///
  /// In en, this message translates to:
  /// **'AI is formulating response...'**
  String get aiFormulating;

  /// Section title for PubChem info
  ///
  /// In en, this message translates to:
  /// **'PubChem Data'**
  String get pubChemData;

  /// Label for IUPAC name
  ///
  /// In en, this message translates to:
  /// **'IUPAC Name'**
  String get iupacName;

  /// Label for molecular formula
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// Label for molecular weight
  ///
  /// In en, this message translates to:
  /// **'Molecular Weight'**
  String get molecularWeight;

  /// Success message for a valid reaction
  ///
  /// In en, this message translates to:
  /// **'Reaction Occurred!'**
  String get reactionOccurred;

  /// Message when no reaction occurs
  ///
  /// In en, this message translates to:
  /// **'No Reaction'**
  String get noReaction;

  /// Label for the reaction product
  ///
  /// In en, this message translates to:
  /// **'Product: {name}'**
  String productName(String name);

  /// Tooltip for clearing chat
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChat;

  /// Banner when AI is offline
  ///
  /// In en, this message translates to:
  /// **'AI Tutor Unavailable'**
  String get aiTutorUnavailable;

  /// Error message when API key is missing
  ///
  /// In en, this message translates to:
  /// **'The AI tutor requires a Gemini API key.'**
  String get aiTutorRequiresKey;

  /// Welcome msg for AI tutor
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about\nOrganic Chemistry!'**
  String get askAnything;

  /// AI tutor capabilities info
  ///
  /// In en, this message translates to:
  /// **'I can explain reactions, concepts,\nand help you understand chemistry better.'**
  String get iCanExplain;

  /// Shown when AI is processing a chat query
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get thinking;

  /// Hint for chat input
  ///
  /// In en, this message translates to:
  /// **'Ask a chemistry question…'**
  String get askAQuestion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
