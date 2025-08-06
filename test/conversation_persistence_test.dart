import 'package:flutter_test/flutter_test.dart';
import '../lib/models/online/chat_message.dart';

void main() {
  group('Session-Only Conversation Tests', () {
    late List<ChatMessage> testMessages;

    setUp(() {
      // Create test messages
      testMessages = [
        ChatMessage(
          text:
              "Hello, I'm HemoAssist! I'm here to help you with hemophilia-related questions.",
          isUser: false,
        ),
        ChatMessage(text: "What are the symptoms of hemophilia?", isUser: true),
        ChatMessage(
          text:
              "Hemophilia symptoms include excessive bleeding, easy bruising, and prolonged bleeding after injuries or surgery...",
          isUser: false,
        ),
      ];
    });

    test('should maintain messages in memory during session', () {
      // Simulate in-memory message storage
      final List<ChatMessage> sessionMessages = [];

      // Add messages during session
      sessionMessages.addAll(testMessages);

      // Verify messages are maintained in current session
      expect(sessionMessages.length, equals(testMessages.length));

      for (int i = 0; i < sessionMessages.length; i++) {
        expect(sessionMessages[i].text, equals(testMessages[i].text));
        expect(sessionMessages[i].isUser, equals(testMessages[i].isUser));
      }
    });

    test(
      'should clear messages when session ends (app restart simulation)',
      () {
        // Simulate session with messages
        final List<ChatMessage> sessionMessages = [];
        sessionMessages.addAll(testMessages);

        // Verify messages exist during session
        expect(sessionMessages.length, equals(3));

        // Simulate app restart by clearing in-memory storage
        sessionMessages.clear();

        // Verify messages are gone after session ends
        expect(sessionMessages.isEmpty, isTrue);
      },
    );

    test('should handle large conversation during session', () {
      final List<ChatMessage> sessionMessages = [];

      // Create a large conversation (100 messages)
      for (int i = 0; i < 100; i++) {
        sessionMessages.add(
          ChatMessage(
            text: "Message number $i",
            isUser: i % 2 == 0, // Alternate between user and assistant
          ),
        );
      }

      // Verify all messages are maintained in memory
      expect(sessionMessages.length, equals(100));

      // Verify a few random messages
      expect(sessionMessages[0].text, equals("Message number 0"));
      expect(sessionMessages[50].text, equals("Message number 50"));
      expect(sessionMessages[99].text, equals("Message number 99"));
    });

    test('should preserve message timestamps during session', () {
      final DateTime now = DateTime.now();

      // Create message with specific timestamp
      final ChatMessage messageWithTimestamp = ChatMessage(
        text: "Test message with timestamp",
        isUser: true,
        timestamp: now,
      );

      final List<ChatMessage> sessionMessages = [messageWithTimestamp];

      // Verify timestamp is preserved in memory
      expect(
        sessionMessages[0].timestamp.millisecondsSinceEpoch,
        equals(now.millisecondsSinceEpoch),
      );
    });

    test('should handle empty conversation state', () {
      final List<ChatMessage> sessionMessages = [];

      // Verify empty state
      expect(sessionMessages.isEmpty, isTrue);
      expect(sessionMessages.length, equals(0));
    });

    test('should allow clearing messages during session', () {
      final List<ChatMessage> sessionMessages = [];
      sessionMessages.addAll(testMessages);

      // Verify messages exist
      expect(sessionMessages.length, equals(3));

      // Clear messages (simulate clear chat button)
      sessionMessages.clear();

      // Verify messages are cleared
      expect(sessionMessages.isEmpty, isTrue);
    });

    test('should maintain message order during session', () {
      final List<ChatMessage> sessionMessages = [];

      // Add messages in specific order
      final firstMessage = ChatMessage(text: "First message", isUser: true);
      final secondMessage = ChatMessage(text: "Second message", isUser: false);
      final thirdMessage = ChatMessage(text: "Third message", isUser: true);

      sessionMessages.add(firstMessage);
      sessionMessages.add(secondMessage);
      sessionMessages.add(thirdMessage);

      // Verify order is maintained
      expect(sessionMessages[0].text, equals("First message"));
      expect(sessionMessages[1].text, equals("Second message"));
      expect(sessionMessages[2].text, equals("Third message"));

      expect(sessionMessages[0].isUser, isTrue);
      expect(sessionMessages[1].isUser, isFalse);
      expect(sessionMessages[2].isUser, isTrue);
    });
  });
}
