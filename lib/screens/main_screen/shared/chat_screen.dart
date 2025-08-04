import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../../services/message_service.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> participant;
  final String currentUserRole;

  const ChatScreen({
    super.key,
    required this.participant,
    required this.currentUserRole,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final MessageService _messageService = MessageService();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _currentUserId;
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    // Try Firebase Auth first, then fall back to secure storage
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      print('ChatScreen: Using Firebase Auth user ID: $_currentUserId');
    } else {
      _currentUserId = await _secureStorage.read(key: 'userUid');
      print('ChatScreen: Using secure storage user ID: $_currentUserId');
    }

    if (_currentUserId != null) {
      _setupMessageStream();
    } else {
      print('ChatScreen: No user ID found!');
    }
  }

  void _setupMessageStream() {
    if (_currentUserId == null) return;

    final participantId =
        widget.participant['id'] ?? widget.participant['uid'] ?? '';
    print(
      'Setting up message stream between $_currentUserId and $participantId',
    );

    setState(() => _isLoading = true);

    _messageSubscription?.cancel();
    _messageSubscription = _messageService
        .getMessagesStream(_currentUserId!, participantId)
        .listen(
          (messages) {
            print('Received ${messages.length} messages in chat stream');
            setState(() {
              _messages = messages;
              _isLoading = false;
            });
            _scrollToBottom();
          },
          onError: (error) {
            print('Error in message stream: $error');
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load messages: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      final message = await _messageService.sendMessage(
        senderId: _currentUserId ?? '',
        receiverId: widget.participant['id'] ?? widget.participant['uid'] ?? '',
        message: messageText,
        senderRole: widget.currentUserRole,
      );

      print('Message sent successfully: ${message['id']}');

      _scrollToBottom();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Message sent'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isSending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.redAccent.withOpacity(0.2),
              child: Icon(
                widget.participant['role'] == 'medical'
                    ? FontAwesomeIcons.userDoctor
                    : FontAwesomeIcons.user,
                color: Colors.redAccent,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.participant['name'] ?? 'Unknown User',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.participant['role'] == 'medical'
                        ? 'Healthcare Provider'
                        : 'Patient',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.phone, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Voice call feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.video, size: 18),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Video call feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.redAccent),
                        SizedBox(height: 16),
                        Text('Loading messages...'),
                      ],
                    ),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.comments,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start a conversation with ${widget.participant['name']}',
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isCurrentUser =
                          message['senderId'] == _currentUserId;

                      return _buildMessageBubble(message, isCurrentUser);
                    },
                  ),
          ),

          // Message Input
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.redAccent),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            FontAwesomeIcons.paperPlane,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isCurrentUser) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(
                FontAwesomeIcons.user,
                size: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.redAccent : Colors.grey[200],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isCurrentUser
                      ? Radius.circular(18)
                      : Radius.circular(4),
                  bottomRight: isCurrentUser
                      ? Radius.circular(4)
                      : Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'] ?? '',
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message['timestamp']),
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.redAccent.withOpacity(0.2),
              child: Icon(
                FontAwesomeIcons.user,
                size: 14,
                color: Colors.redAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatMessageTime(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime time;
    if (timestamp is DateTime) {
      time = timestamp;
    } else if (timestamp is String) {
      time = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
