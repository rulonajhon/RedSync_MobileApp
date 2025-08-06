import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static String? _apiKey;
  static const String _baseUrl = 'https://api.openai.com/v1';

  static Future<void> initialize() async {
    await dotenv.load(fileName: "assets/.env");
    _apiKey = dotenv.env['OPENAI_API_KEY'];
    if (_apiKey == null ||
        _apiKey!.isEmpty ||
        _apiKey == 'your_openai_api_key_here') {
      throw Exception(
        'OpenAI API key not found or not configured in .env file',
      );
    }
  }

  static Future<String> generateResponse(
    String prompt,
    List<Map<String, String>> chatHistory,
  ) async {
    if (_apiKey == null) {
      throw Exception('OpenAI service not initialized');
    }

    // Pre-validation: Check if the question is hemophilia-related
    if (!_isHemophiliaRelated(prompt)) {
      return _getOffTopicResponse();
    }

    // Create enhanced system message with strict content filtering
    final List<Map<String, String>> messages = [
      {'role': 'system', 'content': _getSystemPrompt()},
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
      final responseContent = data['choices'][0]['message']['content'];

      // Post-validation: Ensure response is hemophilia-focused
      if (!_isResponseAppropriate(responseContent)) {
        return _getOffTopicResponse();
      }

      return responseContent;
    } else {
      throw Exception(
        'Failed to generate response: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Public test methods for unit testing
  static bool isHemophiliaRelatedForTesting(String prompt) {
    return _isHemophiliaRelated(prompt);
  }

  static String getOffTopicResponseForTesting() {
    return _getOffTopicResponse();
  }

  /// Checks if the user's question is related to hemophilia
  static bool _isHemophiliaRelated(String prompt) {
    final lowercasePrompt = prompt.toLowerCase();

    // Allow basic greetings and conversational starters
    final greetings = [
      'hi',
      'hello',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
      'greetings',
      'how are you',
      'what can you do',
      'what can you help with',
      'what are you',
      'who are you',
      'help',
      'start',
      'begin',
    ];

    // Check for greetings first
    for (final greeting in greetings) {
      if (lowercasePrompt.trim() == greeting ||
          lowercasePrompt.startsWith('$greeting ') ||
          lowercasePrompt.startsWith('$greeting!') ||
          lowercasePrompt.startsWith('$greeting.')) {
        return true;
      }
    }

    // Check for simple greeting patterns
    if (lowercasePrompt.trim().length <= 20) {
      for (final greeting in greetings) {
        if (lowercasePrompt.contains(greeting) && 
            !lowercasePrompt.contains('weather') &&
            !lowercasePrompt.contains('joke') &&
            !lowercasePrompt.contains('cook') &&
            !lowercasePrompt.contains('pasta') &&
            !lowercasePrompt.contains('football') &&
            !lowercasePrompt.contains('score')) {
          return true;
        }
      }
    }

    // Hemophilia-related keywords
    final hemophiliaKeywords = [
      'hemophilia',
      'haemophilia',
      'bleeding',
      'factor',
      'clotting',
      'coagulation',
      'von willebrand',
      'vwd',
      'blood disorder',
      'hemorrhage',
      'joint pain',
      'swelling',
      'bruising',
      'nosebleed',
      'factor viii',
      'factor ix',
      'factor xi',
      'prophylaxis',
      'infusion',
      'concentrate',
      'plasma',
      'medication',
      'treatment',
      'symptoms',
      'diagnosis',
      'genetic',
      'inherited',
      'disorder',
      'bleeding time',
      'platelet',
      'thrombin',
      'fibrin',
      'clot',
      'hematoma',
      'ecchymosis',
      'petechiae',
      'purpura',
      'blood transfusion',
      'surgery',
      'dental',
      'emergency',
      'sports',
      'exercise',
      'activity',
      'lifestyle',
      'diet',
      'nutrition',
      'supplements',
      'iron',
      'vitamin',
      'pain management',
      'physical therapy',
      'orthopedic',
      'arthritis',
      'joint replacement',
      'mobility',
      'pregnancy',
      'childbirth',
      'women',
      'menstruation',
      'insurance',
      'cost',
      'financial',
      'support group',
      'family',
      'children',
      'school',
      'work',
      'travel',
      // Additional pain and symptom keywords
      'pain',
      'ache',
      'hurt',
      'sore',
      'tender',
      'stiff',
      'swollen',
      'inflamed',
      'bruise',
      'bump',
      'lump',
      'soreness',
      'stiffness',
      'discomfort',
      'aching',
      'throbbing',
      // Body parts commonly affected by hemophilia
      'joint',
      'joints',
      'knee',
      'knees',
      'ankle',
      'ankles',
      'elbow',
      'elbows',
      'wrist',
      'wrists',
      'hip',
      'hips',
      'shoulder',
      'shoulders',
      'foot',
      'feet',
      'leg',
      'legs',
      'arm',
      'arms',
      'muscle',
      'muscles',
    ];

    // Check if any hemophilia-related keywords are present
    for (final keyword in hemophiliaKeywords) {
      if (lowercasePrompt.contains(keyword)) {
        return true;
      }
    }

    // Special check for symptom descriptions (pain/discomfort + body parts)
    final painWords = [
      'pain',
      'hurt',
      'ache',
      'sore',
      'tender',
      'stiff',
      'swollen',
      'inflamed',
      'discomfort',
      'aching',
      'throbbing',
      'soreness',
      'stiffness',
    ];
    final bodyParts = [
      'joint',
      'joints',
      'knee',
      'knees',
      'ankle',
      'ankles',
      'elbow',
      'elbows',
      'wrist',
      'wrists',
      'hip',
      'hips',
      'shoulder',
      'shoulders',
      'foot',
      'feet',
      'leg',
      'legs',
      'arm',
      'arms',
      'muscle',
      'muscles',
    ];

    // Check if the prompt contains pain-related words AND body parts (likely hemophilia symptoms)
    bool hasPainWord = false;
    bool hasBodyPart = false;

    for (final painWord in painWords) {
      if (lowercasePrompt.contains(painWord)) {
        hasPainWord = true;
        break;
      }
    }

    for (final bodyPart in bodyParts) {
      if (lowercasePrompt.contains(bodyPart)) {
        hasBodyPart = true;
        break;
      }
    }

    // If both pain and body part are mentioned, it's likely hemophilia-related
    if (hasPainWord && hasBodyPart) {
      return true;
    }

    // Check for "feel" + symptom combinations (e.g., "I feel pain", "I feel swollen")
    if (lowercasePrompt.contains('feel') && hasPainWord) {
      return true;
    }

    // Check for symptom reporting phrases
    final symptomPhrases = [
      'i have pain',
      'i feel pain',
      'i have swelling',
      'i feel swollen',
      'my joints',
      'my knee',
      'my ankle',
      'my elbow',
      'my wrist',
      'my hip',
      'my shoulder',
      'my foot',
      'my feet',
      'my leg',
      'my arm',
      'it hurts',
      'is sore',
      'is swollen',
      'is tender',
      'feels stiff',
    ];

    for (final phrase in symptomPhrases) {
      if (lowercasePrompt.contains(phrase)) {
        return true;
      }
    }

    // Additional context-based checking
    final medicalContextWords = [
      'doctor',
      'physician',
      'hospital',
      'clinic',
      'medical',
      'health',
      'patient',
      'treatment',
      'therapy',
      'medicine',
      'prescription',
      'dose',
      'side effect',
      'reaction',
    ];

    int medicalContextCount = 0;
    for (final word in medicalContextWords) {
      if (lowercasePrompt.contains(word)) {
        medicalContextCount++;
      }
    }

    // If it contains multiple medical context words, it might be hemophilia-related
    if (medicalContextCount >= 2) {
      return true;
    }

    return false;
  }

  /// Validates if the AI response is appropriate and hemophilia-focused
  static bool _isResponseAppropriate(String response) {
    final lowercaseResponse = response.toLowerCase();

    // Check if response mentions hemophilia or related terms
    final relevantTerms = [
      'hemophilia',
      'haemophilia',
      'bleeding',
      'factor',
      'clotting',
      'blood disorder',
      'coagulation',
      'medical advice',
      'healthcare',
      'physician',
      'doctor',
      'treatment',
      'symptoms',
      'disorder',
    ];

    for (final term in relevantTerms) {
      if (lowercaseResponse.contains(term)) {
        return true;
      }
    }

    // If the response is very short and doesn't contain relevant terms,
    // it might be off-topic
    if (response.length < 50) {
      return false;
    }

    return true;
  }

  /// Returns a standard response for off-topic questions
  static String _getOffTopicResponse() {
    return """I'm HemoAssistant, and I'm specifically designed to help with hemophilia-related questions and concerns. 

I can assist you with understanding hemophilia types and symptoms, treatment options, lifestyle recommendations, emergency care, and emotional support resources.

Is there something specific about hemophilia I can help you with today?""";
  }

  /// Returns the enhanced system prompt with strict content filtering
  static String _getSystemPrompt() {
    return '''You are HemoAssistant, an AI assistant specialized in hemophilia care and management. 
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
        
        Always remind users that your advice doesn't replace professional medical consultation.
        
        IMPORTANT: Only answer questions related to hemophilia and bleeding disorders. If asked about unrelated topics, politely redirect to hemophilia-related questions.''';
  }
}
