import 'dart:convert';
import 'package:http/http.dart' as http;

class AiAnalysisService {
  // IMPORTANT : remplace par ta vraie clé OpenAI
  static const String _apiKey = 'TA_CLE_OPENAI_ICI';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  static Future<String> quickAdviceFromContext({
    required Map<String, dynamic> contextData,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception("Clé API IA manquante.");
    }

    final prompt = _buildContextPrompt(contextData);

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content':
            "Tu es un instructeur de pilotage. Tu donnes des conseils courts et concrets au pilote en te basant sur les données de vol, en français."
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.4,
        'max_tokens': 200,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Erreur IA (${response.statusCode}) : ${response.body}');
    }

    final data = jsonDecode(response.body);
    final text = data['choices'][0]['message']['content'] as String;
    return text.trim();
  }

  static String _buildContextPrompt(Map<String, dynamic> ctx) {
    final buf = StringBuffer();

    buf.writeln("Voici la situation de vol actuelle :");
    ctx.forEach((key, value) {
      buf.writeln("- $key : $value");
    });
    buf.writeln(
        "À partir de ces données, donne un conseil de pilotage simple (1 ou 2 phrases maximum), "
            "en précisant quoi surveiller ou ajuster.");

    return buf.toString();
  }
}