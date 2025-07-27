import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static String? _apiKey;
  static const String _baseUrl = 'https://api.openai.com/v1';

  static Future<void> initialize() async {
    await dotenv.load(fileName: "assets/.env");
    _apiKey = dotenv.env['OPENAI_API_KEY'];
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OpenAI API key not found in .env file');
    }
  }

  static Future<String> generateResponse(
    String prompt,
    List<Map<String, String>> chatHistory,
  ) async {
    if (_apiKey == null) {
      throw Exception('OpenAI service not initialized');
    }

    // Create system message with hemophilia context
    final List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content':
            '''You are HemoAssistant, an AI assistant specialized in hemophilia care and management. 
        You provide helpful, accurate information about hemophilia, its symptoms, treatments, lifestyle management, 
        and support resources. Always encourage users to consult with their healthcare providers for medical advice. 
        Be empathetic, supportive, and provide evidence-based information.
        
        Key areas you can help with:
        - Hemophilia types (A, B, C) and severity levels
        - Factor replacement therapy
        - Bleeding prevention and management
        - Exercise and activity recommendations
        - Diet and nutrition
        - Emergency situations
        - Emotional support and coping strategies
        - Insurance and financial resources
        
        Always remind users that your advice doesn't replace professional medical consultation.''',
      },
      ...chatHistory,
      {'role': 'user', 'content': prompt},
    ];

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': messages,
        'max_tokens': 800,
        'temperature': 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(
        'Failed to generate response: ${response.statusCode} - ${response.body}',
      );
    }
  }
}