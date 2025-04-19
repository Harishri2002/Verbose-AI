import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TextService {
  final String apiKey = dotenv.env['API_URL'] ?? 'default_url'; // Your Hugging Face API key
  final String apiUrl = "https://router.huggingface.co/nebius/v1/chat/completions";
  final String modelId = "google/gemma-2-2b-it";
  TextService();

  Future<String> standardizeText(String text) async {
    try {
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "model": modelId,
        "messages": [
          {
            "role": "system",
            "content": "You are a professional editor. Correct grammar and spelling, and rewrite the text in a formal, professional tone without changing its meaning and dont add anything extra keep or update the obtained text"
          },
          {
            "role": "user",
            "content": text
          }
        ],
        "temperature": 0.3,
        "max_tokens": 150
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final standardized = responseData['choices'][0]['message']['content'];
        return standardized.trim();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to standardize text: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error using API: $e');
      return _fallbackStandardization(text);
    }
  }

  String _fallbackStandardization(String text) {
    String standardized = text
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' i ', ' I ');

    if (standardized.isNotEmpty) {
      standardized = standardized[0].toUpperCase() + standardized.substring(1);
      if (!standardized.endsWith('.') &&
          !standardized.endsWith('!') &&
          !standardized.endsWith('?')) {
        standardized += '.';
      }
    }

    return standardized;
  }
}
