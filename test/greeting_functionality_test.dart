import 'package:flutter_test/flutter_test.dart';
import '../lib/services/openai_service.dart';

void main() {
  group('OpenAI Service Greeting Tests', () {
    test('should allow basic greetings', () {
      expect(OpenAIService.isHemophiliaRelatedForTesting('hi'), isTrue);
      expect(OpenAIService.isHemophiliaRelatedForTesting('hello'), isTrue);
      expect(OpenAIService.isHemophiliaRelatedForTesting('hey'), isTrue);
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('good morning'),
        isTrue,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('how are you'),
        isTrue,
      );
    });

    test('should allow conversational starters', () {
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('what can you do'),
        isTrue,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('what can you help with'),
        isTrue,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('who are you'),
        isTrue,
      );
      expect(OpenAIService.isHemophiliaRelatedForTesting('help'), isTrue);
    });

    test('should still allow hemophilia-related terms', () {
      expect(OpenAIService.isHemophiliaRelatedForTesting('hemophilia'), isTrue);
      expect(OpenAIService.isHemophiliaRelatedForTesting('bleeding'), isTrue);
      expect(OpenAIService.isHemophiliaRelatedForTesting('factor'), isTrue);
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('i feel pain in my feet'),
        isTrue,
      );
    });

    test('should still block non-hemophilia topics', () {
      // Test each separately to identify which one fails
      print(
        'Testing: what is the weather - ${OpenAIService.isHemophiliaRelatedForTesting('what is the weather')}',
      );
      print(
        'Testing: tell me a joke - ${OpenAIService.isHemophiliaRelatedForTesting('tell me a joke')}',
      );
      print(
        'Testing: how to cook pasta - ${OpenAIService.isHemophiliaRelatedForTesting('how to cook pasta')}',
      );
      print(
        'Testing: football scores - ${OpenAIService.isHemophiliaRelatedForTesting('football scores')}',
      );
      print(
        'Testing: basketball scores - ${OpenAIService.isHemophiliaRelatedForTesting('basketball scores')}',
      );
      print(
        'Testing: movie recommendations - ${OpenAIService.isHemophiliaRelatedForTesting('movie recommendations')}',
      );

      expect(
        OpenAIService.isHemophiliaRelatedForTesting('what is the weather'),
        isFalse,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('tell me a joke'),
        isFalse,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('how to cook pasta'),
        isFalse,
      );
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('movie recommendations'),
        isFalse,
      );
    });

    test('should handle greeting variations', () {
      expect(OpenAIService.isHemophiliaRelatedForTesting('Hi there'), isTrue);
      expect(OpenAIService.isHemophiliaRelatedForTesting('Hello!'), isTrue);
      expect(OpenAIService.isHemophiliaRelatedForTesting('Hey there!'), isTrue);
      expect(
        OpenAIService.isHemophiliaRelatedForTesting('Good morning doctor'),
        isTrue,
      );
    });
  });
}
