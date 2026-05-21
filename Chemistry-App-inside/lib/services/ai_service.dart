import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart'
    as http; // 👈 කෙලින්ම HTTP රික්වෙස්ට් දාන්න මේක ඕනේ

class AiService {
  final String apiKey;
  bool _isInitialized = false;

  static const String _modelName = 'llama-3.3-70b-versatile';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions'; // 🎯 නිවැරදිම URL එක

  static const _systemInstruction = '''
You are ChemLearn Tutor, a friendly and encouraging organic chemistry tutor and reaction predictor for beginner students (school level).
RULES:
1. ONLY answer questions or predict results about organic chemistry topics.
2. Use simple language, analogies, and keep explanations under 200 words.
3. Format key terms in **bold** for emphasis.
4. When asked to predict a reaction, strictly output a structured JSON object matching the requested schema.
''';

  AiService({required this.apiKey}) {
    if (apiKey.isEmpty) {
      debugPrint('AiService: No API key provided.');
      return;
    }
    _isInitialized = true;
    debugPrint(
      '🚀 AiService successfully initialized with Groq Direct HTTP ($_modelName)',
    );
  }

  bool get isAvailable => _isInitialized;

  // ────────────────────────────────────────────────────────────
  // REACTION PREDICTION (Practice Lab)
  // ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> predictReaction({
    required List<String> reactantNames,
    required String condition,
  }) async {
    if (!_isInitialized) return null;

    final prompt =
        '''
Predict the organic chemistry product for the following mixture:
Reactants: ${reactantNames.join(' + ')}
Condition: $condition

If a reaction occurs, predict the primary organic product. 
If NO reaction occurs, set product_name to "No Reaction", formula to "N/A", and type to "none".

You MUST respond ONLY with a raw JSON object matching this schema exactly. Do not include markdown like ```json.
{
  "product_name": "Common or IUPAC name of the product",
  "formula": "Standard condensed chemical formula without spaces",
  "type": "addition, substitution, elimination, combustion, or none",
  "explanation": "A short, beginner-friendly explanation of how this reaction happens."
}
''';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _modelName,
          'response_format': {'type': 'json_object'}, // Force JSON format
          'temperature': 0.1,
          'messages': [
            {'role': 'system', 'content': _systemInstruction},
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jsonText = data['choices'][0]['message']['content'];
        return jsonDecode(jsonText) as Map<String, dynamic>;
      } else {
        debugPrint(
          'Groq HTTP Error: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('AiService prediction error: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────
  // FREEFORM TUTOR Q&A (Chat History එක්කම)
  // ────────────────────────────────────────────────────────────
  final List<Map<String, String>> _chatHistory = [];

  Future<String?> askTutor(String question) async {
    if (!_isInitialized) return null;

    try {
      if (_chatHistory.isEmpty) {
        _chatHistory.add({'role': 'system', 'content': _systemInstruction});
      }

      _chatHistory.add({'role': 'user', 'content': question});

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _modelName,
          'temperature': 0.7,
          'messages': _chatHistory,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText = data['choices'][0]['message']['content'] as String;

        _chatHistory.add({'role': 'assistant', 'content': replyText});
        return replyText;
      } else {
        debugPrint(
          '🚨 GROQ HTTP TUTOR ERROR: ${response.statusCode} - ${response.body}',
        );
        return 'AI Error: Server returned an error (${response.statusCode})';
      }
    } catch (e) {
      debugPrint('🚨 GROQ AI TUTOR CRASH LOG: $e');
      return 'AI Error: Something went wrong. Please check your connection.';
    }
  }

  void resetTutorChat() {
    _chatHistory.clear();
  }

  // ────────────────────────────────────────────────────────────
  // EXPLAIN & HINT FALLBACKS
  // ────────────────────────────────────────────────────────────
  Future<String?> explainReaction({
    required List<String> reactantNames,
    required String productName,
    required String reactionType,
    required String localExplanation,
  }) async {
    final prompt =
        'Explain this reaction simply for a beginner: ${reactantNames.join(' + ')} -> $productName ($reactionType). Textbook description: $localExplanation';
    return _generateOneShot(prompt);
  }

  Future<String?> generateHint({
    required List<String> reactantNames,
    required String condition,
    required String localHint,
  }) async {
    final prompt =
        'Give an encouraging chemistry hint for wrong mixture: ${reactantNames.join(' + ')} under $condition. System hint: $localHint. Don\'t give the answer.';
    return _generateOneShot(prompt);
  }

  Future<String?> _generateOneShot(String prompt) async {
    if (!_isInitialized) return null;
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _modelName,
          'temperature': 0.5,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
