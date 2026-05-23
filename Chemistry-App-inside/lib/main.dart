import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/firestore_service.dart';
import 'services/ai_service.dart';
import 'repositories/chemistry_repository.dart';
import 'providers/chemistry_provider.dart';
import 'screens/home_screen.dart';
import 'services/pubchem_service.dart';

/// Entry point for the ChemLearn application.
///
/// Initializes Firebase, sets up dependency injection via Provider,
/// and launches the app with the dark science-inspired theme.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment variables (.env)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init failed (using seed data fallback): $e');
  }

  // 🎯 වෙනස් කළ තැන: .env ෆයිල් එකෙන් API Key එක ලස්සනට කියවගන්නවා
  final geminiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  if (geminiApiKey.isEmpty) {
    debugPrint(
      '⚠️ WARNING: GEMINI_API_KEY is empty in .env file! AI will run in offline mode.',
    );
  } else {
    debugPrint('🚀 AI Service successfully initialized with API Key from .env');
  }

  runApp(ChemLearnApp(geminiApiKey: geminiApiKey));
}

class ChemLearnApp extends StatelessWidget {
  final String geminiApiKey;

  const ChemLearnApp({super.key, required this.geminiApiKey});

  @override
  Widget build(BuildContext context) {
    // Set up dependency graph
    final firestoreService = FirestoreService();
    final repository = ChemistryRepository(firestoreService: firestoreService);
    final aiService = AiService(apiKey: geminiApiKey);
    final pubChemService = PubChemService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = ChemistryProvider(
              repository: repository,
              aiService: aiService,
              pubChemService: pubChemService,
            );
            // Kick off data loading immediately
            provider.initialize();
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'ChemLearn',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
