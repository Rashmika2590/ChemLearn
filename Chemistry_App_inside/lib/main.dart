import 'package:chemistry_app/firebase_options.dart';
import 'package:chemistry_app/l10n/app_localizations.dart';
import 'package:chemistry_app/providers/conversion_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/firestore_service.dart';
import 'services/ai_service.dart';
import 'repositories/chemistry_repository.dart';
import 'repositories/lesson_repository.dart';
import 'providers/chemistry_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/home_screen.dart';
import 'services/pubchem_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }

  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  final geminiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  runApp(
    ChemLearnApp(
      geminiApiKey: geminiApiKey,
      firebaseAvailable: firebaseInitialized,
    ),
  );
}

class ChemLearnApp extends StatelessWidget {
  final String geminiApiKey;
  final bool firebaseAvailable;

  const ChemLearnApp({
    super.key,
    required this.geminiApiKey,
    this.firebaseAvailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = firebaseAvailable ? FirestoreService() : null;
    final repository = ChemistryRepository(firestoreService: firestoreService);
    final pubChemService = PubChemService();

    return MultiProvider(
      providers: [
        // 1. මුලින්ම AI Service එක Provider එකක් ලෙස register කරන්න
        Provider<AiService>(create: (_) => AiService(apiKey: geminiApiKey)),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),

        // 2. ඉතිරි Provider වලට AiService එක inject කරන්න
        ChangeNotifierProxyProvider<LocaleProvider, ChemistryProvider>(
          create: (context) {
            final provider = ChemistryProvider(
              repository: repository,
              aiService: Provider.of<AiService>(context, listen: false),
              pubChemService: pubChemService,
            );
            provider.initialize();
            return provider;
          },
          update: (context, localeProvider, chemistryProvider) {
            if (localeProvider.locale != null) {
              chemistryProvider!.updateLocale(localeProvider.locale!);
            }
            return chemistryProvider!;
          },
        ),
        ChangeNotifierProxyProvider2<
          LocaleProvider,
          ChemistryProvider,
          LessonProvider
        >(
          create: (context) {
            final provider = LessonProvider(
              repository: LessonRepository(),
              chemistryProvider: Provider.of<ChemistryProvider>(
                context,
                listen: false,
              ),
            );
            provider.loadLessons();
            return provider;
          },
          update: (context, localeProvider, chemistryProvider, lessonProvider) {
            if (localeProvider.locale != null) {
              lessonProvider!.updateLocale(localeProvider.locale!.languageCode);
            }
            return lessonProvider!;
          },
        ),
        ChangeNotifierProvider<ConversionProvider>(
          create: (context) => ConversionProvider(
            // මෙතනට අවශ්‍ය dependencies ඇතුලත් කරන්න
          ),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'ChemLearn',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('si')],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
