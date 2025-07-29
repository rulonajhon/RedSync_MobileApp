import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hemophilia_manager/models/online/chat_message.dart';
import 'package:hemophilia_manager/services/openai_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm HemoAssistant, your AI companion for hemophilia care and support. I'm here to help you with:\n\n"
            "• Understanding hemophilia types and symptoms\n"
            "• Treatment and medication guidance\n"
            "• Lifestyle and activity recommendations\n"
            "• Emergency care information\n"
            "• Emotional support and resources\n\n"
            "How can I assist you today?\n\n"
            "*Please remember that I provide informational support only and cannot replace professional medical advice.*",
        isUser: false,
      ),
    );
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final userMessage = _textController.text.trim();
    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // Convert messages to format expected by OpenAI API
      // Exclude the just-added user message from history
      final chatHistory = _messages
          .where((msg) => _messages.indexOf(msg) != _messages.length - 1)
          .map((msg) => msg.toMap())
          .toList();

      final response = await OpenAIService.generateResponse(
        userMessage,
        chatHistory,
      );

      if (response.isNotEmpty) {
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  "I'm sorry, I couldn't generate a response at the moment. Please try asking your question again.",
              isUser: false,
            ),
          );
          _isLoading = false;
        });
      }

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "I apologize, but I'm having trouble connecting right now. Please check your internet connection and try again. If the problem persists, you may need to verify your API configuration.",
            isUser: false,
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.red.shade700,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.red.shade700,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HemoAssistant',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red.shade700,
                  ),
                ),
                Text(
                  'AI Medical Assistant',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.refresh, size: 20),
              ),
              onPressed: () {
                setState(() {
                  _messages.clear();
                  _addWelcomeMessage();
                });
              },
              tooltip: 'Clear chat',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Header Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This AI assistant provides health information only. Always consult healthcare professionals for medical decisions.',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages Area
          Expanded(
            child: _messages.isEmpty && !_isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildLoadingMessage();
                      }

                      final message = _messages[index];
                      return _buildMessageBubble(message, index);
                    },
                  ),
          ),

          // Input Area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.smart_toy, size: 40, color: Colors.red.shade700),
          ),
          SizedBox(height: 24),
          Text(
            'Welcome to HemoAssistant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start a conversation to get personalized hemophilia care assistance',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isConsecutive =
        index > 0 && _messages[index - 1].isUser == message.isUser;

    return Container(
      margin: EdgeInsets.only(
        bottom: isConsecutive ? 4 : 16,
        top: index == 0 ? 0 : (isConsecutive ? 0 : 8),
      ),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            if (!isConsecutive)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: Colors.red.shade700,
                  size: 16,
                ),
              )
            else
              SizedBox(width: 32),
            SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.red.shade700 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    message.isUser ? 20 : (isConsecutive ? 8 : 20),
                  ),
                  topRight: Radius.circular(
                    message.isUser ? (isConsecutive ? 8 : 20) : 20,
                  ),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: message.isUser
                    ? null
                    : Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: message.isUser
                  ? Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        strong: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                        em: TextStyle(fontStyle: FontStyle.italic),
                        listBullet: TextStyle(color: Colors.red.shade700),
                        code: TextStyle(
                          backgroundColor: Colors.grey.shade100,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
            ),
          ),

          if (message.isUser) ...[
            SizedBox(width: 8),
            if (!isConsecutive)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person, color: Colors.white, size: 16),
              )
            else
              SizedBox(width: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.smart_toy, color: Colors.red.shade700, size: 16),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.red.shade700,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'HemoAssistant is thinking...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Quick suggestion chips
            if (_messages.length <= 1) ...[
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSuggestionChip('What is hemophilia?'),
                    SizedBox(width: 8),
                    _buildSuggestionChip('Treatment options'),
                    SizedBox(width: 8),
                    _buildSuggestionChip('Emergency care'),
                    SizedBox(width: 8),
                    _buildSuggestionChip('Daily activities'),
                  ],
                ),
              ),
              SizedBox(height: 12),
            ],

            // Input field and send button
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Ask me about hemophilia care...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: FloatingActionButton(
                    heroTag:
                        "chatbot_send_fab", // Unique tag to avoid conflicts
                    mini: true,
                    backgroundColor: Colors.red.shade700,
                    elevation: 0,
                    onPressed: _isLoading ? null : _sendMessage,
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _textController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
