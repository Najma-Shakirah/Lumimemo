import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Gemini 2.5 Flash conversation service with memory-aware system prompt.
///
/// Each [GeminiService] instance holds its own conversation history
/// so you can have a stateful multi-turn chat.
class GeminiService {
  // ── Gemini 2.5 Flash (a.k.a. "Gemini Flash 3") ────────────────────────────
  static const String _model = 'gemini-2.5-flash-preview-04-17';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static String get _apiKey =>
      (dotenv.env['GEMINI_API_KEY'] ?? '').replaceAll('"', '').replaceAll("'", '');

  // Conversation history in Gemini format
  final List<Map<String, dynamic>> _history = [];

  // ── Send a message and get a reply ────────────────────────────────────────

  /// [userMessage] – what the user just said.
  /// [memoryContext] – formatted string of stored memories to inject.
  /// [patientName] – companion's patient name for personalisation.
  Future<String> chat({
    required String userMessage,
    required String memoryContext,
    required String patientName,
  }) async {
    if (_apiKey.isEmpty) {
      return "Error: GEMINI_API_KEY is not set in .env";
    }

    // Append user turn to history
    _history.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ],
    });

    final systemInstruction = _buildSystemPrompt(patientName, memoryContext);

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      },
      'contents': _history,
      'generationConfig': {
        'temperature': 0.8,
        'maxOutputTokens': 512,
        'topP': 0.95,
      },
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String? ??
            "I'm not sure what to say.";

        // Append model reply to history for next turn
        _history.add({
          'role': 'model',
          'parts': [
            {'text': text}
          ],
        });

        return text;
      } else {
        return 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Connection failed: $e';
    }
  }

  // ── Extract memories from a conversation exchange ─────────────────────────

  /// Returns a list of {text, category} maps for newly discovered facts.
  /// Should be called after each conversation turn.
  static Future<List<Map<String, String>>> extractMemories({
    required String userSaid,
    required String companionSaid,
    required String patientName,
  }) async {
    if (_apiKey.isEmpty) return [];

    const extractionPrompt = '''
You are a memory extraction assistant for a dementia care app.
Extract any personal facts, preferences, relationships, events or places 
mentioned by the user in the conversation snippet below.
Only extract clear factual statements — ignore greetings or filler.
Return ONLY a valid JSON array (no markdown) like:
[{"text": "...", "category": "..."}]
Categories must be one of: family, hobby, place, food, event, health, pet, work, other.
If nothing meaningful was revealed, return [].
''';

    final snippet = 'User said: "$userSaid"\nCompanion said: "$companionSaid"';

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$extractionPrompt\n\n$snippet'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 256,
      },
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final raw = data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String? ?? '[]';

        // Strip any markdown fences just in case
        final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
        final List<dynamic> parsed = jsonDecode(cleaned);
        return parsed
            .whereType<Map<String, dynamic>>()
            .map((e) => {
                  'text': (e['text'] as String?) ?? '',
                  'category': (e['category'] as String?) ?? 'other',
                })
            .where((m) => m['text']!.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ── Reset conversation (e.g. on new session) ──────────────────────────────

  void reset() => _history.clear();

  // ── System prompt builder ─────────────────────────────────────────────────

  static String _buildSystemPrompt(String patientName, String memoryContext) {
    return '''
You are Lumi, a warm and caring AI companion specifically designed to help 
$patientName, who lives with memory challenges.

Your role:
- Speak slowly, gently, and with short clear sentences.
- Be patient, never correct the user harshly.
- Reminisce warmly about their past when relevant.
- Bring comfort and joy — you are a trusted friend.
- Keep responses under 3 sentences so they are easy to follow.

What you remember about $patientName:
$memoryContext

Use these memories naturally in conversation to make $patientName feel known and valued.
Never make up facts that are not in the memory list above.
''';
  }
}
