import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService {
  final String apiKey;
  bool _isInitialized = false;

  static const String _modelName = 'llama-3.3-70b-versatile';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

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

  String _getLanguageInstruction(bool isSinhala) {
    if (isSinhala) {
      return 'Respond in fluent, natural Sinhala. Keep chemical names, formulas, and technical terminology in English where appropriate, but explain the reaction and logic entirely in Sinhala.';
    } else {
      return 'Respond in clear, simple English.';
    }
  }

  // ────────────────────────────────────────────────────────────
  // REACTION PREDICTION (Practice Lab)
  // ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> predictReaction({
    required List<String> reactantNames,
    required String condition,
    bool isSinhala = false,
  }) async {
    if (!_isInitialized) return null;

    // මෙන්න මේ variable එක හදන්න ඕනේ මචං
    final langInstruction = _getLanguageInstruction(isSinhala);

    final prompt =
        '''
$langInstruction
Predict the organic chemistry product for the following mixture:
Reactants: ${reactantNames.join(' + ')}
Condition: $condition

IMPORTANT: You MUST respond ONLY with a raw JSON object. 
Keep JSON keys (product_name, formula, type, explanation) in English.
Translate only the values of the JSON fields into the requested language (Sinhala or English).

{
  "product_name": "Common or IUPAC name of the product",
  "formula": "Standard condensed chemical formula without spaces",
  "type": "addition, substitution, elimination, combustion, or none",
  "explanation": "A short, beginner-friendly explanation of how this reaction happens."
}
''';

    // ඉතුරු ටික මෙහෙමමයි...

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _modelName,
          'response_format': {'type': 'json_object'},
          'temperature': 0.1,
          'messages': [
            {
              'role': 'system',
              'content':
                  '$_systemInstruction\n${_getLanguageInstruction(isSinhala)}',
            },
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
  // FREEFORM TUTOR Q&A
  // ────────────────────────────────────────────────────────────
  final List<Map<String, String>> _chatHistory = [];

  Future<String?> askTutor(String question, {bool isSinhala = false}) async {
    if (!_isInitialized) return null;

    try {
      if (_chatHistory.isEmpty) {
        _chatHistory.add({
          'role': 'system',
          'content':
              '$_systemInstruction\n${_getLanguageInstruction(isSinhala)}',
        });
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
    bool isSinhala = false,
  }) async {
    final prompt =
        'Explain this reaction simply for a beginner: ${reactantNames.join(' + ')} -> $productName ($reactionType). Textbook description: $localExplanation';
    return _generateOneShot(prompt, isSinhala: isSinhala);
  }

  Future<String?> generateHint({
    required List<String> reactantNames,
    required String condition,
    required String localHint,
    bool isSinhala = false,
  }) async {
    final prompt =
        'Give an encouraging chemistry hint for wrong mixture: ${reactantNames.join(' + ')} under $condition. System hint: $localHint. Don\'t give the answer.';
    return _generateOneShot(prompt, isSinhala: isSinhala);
  }

  Future<String?> _generateOneShot(
    String prompt, {
    bool isSinhala = false,
  }) async {
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
            {'role': 'system', 'content': _getLanguageInstruction(isSinhala)},
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

  // convertions
  Future<Map<String, dynamic>?> getRandomConversion(bool isSinhala) async {
    final prompt = '''
    Give me a random organic chemistry conversion suitable for a school student.
    Return ONLY a raw JSON object with these keys: 
    "start_name", "target_name".
    Ensure the conversion takes 2-3 steps.
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
          'response_format': {'type': 'json_object'},
          'temperature': 0.8, // Randomness එක වැඩි කරන්න
          'messages': [
            {'role': 'system', 'content': _getLanguageInstruction(isSinhala)},
            {'role': 'user', 'content': prompt},
          ],
        }),
      );
      return jsonDecode(
        jsonDecode(response.body)['choices'][0]['message']['content'],
      );
    } catch (e) {
      return null;
    }
  }

  // AiService.dart එකට එකතු කරන්න
  Future<String?> getMechanism(
    String reactant,
    String reagent,
    bool isSinhala,
  ) async {
    final prompt =
        '''
    Show the reaction mechanism for: $reactant + $reagent.
    Explain the electron movement step-by-step using simple terms.
    If in Sinhala, explain in natural Sinhala with English terms for compounds.
  ''';
    return _generateOneShot(prompt, isSinhala: isSinhala);
  }
}
