import 'package:flutter_test/flutter_test.dart';
import 'package:hemophilia_manager/services/openai_service.dart';

void main() {
  group('HemoAssist Content Filtering Tests', () {
    test('Should detect hemophilia-related questions', () {
      // Test hemophilia-related questions that should pass
      expect(
        OpenAIService.isHemophiliaRelatedForTesting("What is hemophilia A?"),
        true,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting(
          "How do I manage bleeding episodes?",
        ),
        true,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting(
          "What sports are safe for hemophilia patients?",
        ),
        true,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting(
          "Tell me about factor replacement therapy",
        ),
        true,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting(
          "What foods help with clotting?",
        ),
        true,
      );
    });

    test(
      'Should detect symptom descriptions that could be hemophilia-related',
      () {
        // Test specific symptom descriptions that should pass
        expect(
          OpenAIService.isHemophiliaRelatedForTesting("I feel pain in my feet"),
          true,
        );
        expect(
          OpenAIService.isHemophiliaRelatedForTesting("My knee hurts"),
          true,
        );
        expect(
          OpenAIService.isHemophiliaRelatedForTesting(
            "I have swelling in my ankle",
          ),
          true,
        );
        expect(
          OpenAIService.isHemophiliaRelatedForTesting("My joints are sore"),
          true,
        );
        expect(
          OpenAIService.isHemophiliaRelatedForTesting(
            "I feel pain in my elbow",
          ),
          true,
        );
        expect(
          OpenAIService.isHemophiliaRelatedForTesting("My wrist is swollen"),
          true,
        );
        expect(
          OpenAIService.isHemophiliaRelatedForTesting(
            "It hurts when I move my hip",
          ),
          true,
        );
      },
    );

    test('Should reject non-hemophilia questions', () {
      // Test non-hemophilia questions that should be blocked
      expect(
        OpenAIService.isHemophiliaRelatedForTesting(
          "What's the weather today?",
        ),
        false,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting("Tell me a joke"),
        false,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting(
          "How do I fix my computer?",
        ),
        false,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting(
          "What's the capital of France?",
        ),
        false,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting("Best restaurants near me"),
        false,
      );
    });

    test('Should handle borderline medical questions appropriately', () {
      // These might pass based on medical context
      expect(
        OpenAIService.isHemophiliaRelatedForTesting(
          "What medications are safe during pregnancy?",
        ),
        true,
      ); // medical context
      expect(
        OpenAIService.isHemophiliaRelatedForTesting(
          "How does genetics affect my condition?",
        ),
        true,
      ); // medical context

      // These should be blocked
      expect(
        OpenAIService.isHemophiliaRelatedForTesting("What is diabetes?"),
        false,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting("How to lose weight?"),
        false,
      );
    });

    test('Should provide appropriate off-topic response', () {
      final response = OpenAIService.getOffTopicResponseForTesting();
      expect(response.contains("HemoAssistant"), true);
      expect(response.contains("hemophilia-related questions"), true);
      expect(response.contains("specifically designed"), true);
    });
  });
}
