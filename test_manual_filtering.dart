import 'package:hemophilia_manager/services/openai_service.dart';

void main() {
  // Test the specific example mentioned by the user
  final testPrompt = "i feel pain in my feet";
  final isHemophiliaRelated = OpenAIService.isHemophiliaRelatedForTesting(
    testPrompt,
  );

  print('Testing: "$testPrompt"');
  print(
    'Result: ${isHemophiliaRelated ? "ALLOWED (hemophilia-related)" : "BLOCKED (not hemophilia-related)"}',
  );

  // Test a few more examples
  final testCases = [
    "I feel pain in my feet",
    "My knee hurts",
    "I have swelling in my ankle",
    "My joints are sore",
    "What's the weather today?",
    "Tell me a joke",
    "I feel tired", // Should be blocked - no body part
    "My foot is sore", // Should be allowed
    "I have pain in my shoulder", // Should be allowed
  ];

  print('\n--- Additional Test Cases ---');
  for (final testCase in testCases) {
    final result = OpenAIService.isHemophiliaRelatedForTesting(testCase);
    print('"$testCase" → ${result ? "ALLOWED" : "BLOCKED"}');
  }
}
