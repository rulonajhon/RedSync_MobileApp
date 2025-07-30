import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Sample message data - replace with actual data from your backend
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'senderName': 'Dr. Sarah Johnson',
      'senderRole': 'Hematologist',
      'lastMessage': 'Your recent blood test results look good. Continue with current medication.',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'isRead': false,
      'avatar': null,
    },
    {
      'id': '2',
      'senderName': 'Nurse Emily Rodriguez',
      'senderRole': 'Clinical Nurse',
      'lastMessage': 'Reminder: Your next appointment is scheduled for tomorrow at 2 PM.',
      'timestamp': DateTime.now().subtract(Duration(hours: 5)),
      'isRead': true,
      'avatar': null,
    },
    {
      'id': '3',
      'senderName': 'Mom (Caregiver)',
      'senderRole': 'Primary Caregiver',
      'lastMessage': 'How are you feeling today? Don\'t forget to take your medication.',
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
      'isRead': true,
      'avatar': null,
    },
  ];

  List<Map<String, dynamic>> _filteredMessages = [];

  @override
  void initState() {
    super.initState();
    _filteredMessages = _messages;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMessages(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMessages = _messages;
      } else {
        _filteredMessages = _messages.where((message) {
          final senderName = message['senderName'].toString().toLowerCase();
          final lastMessage = message['lastMessage'].toString().toLowerCase();
          return senderName.contains(query.toLowerCase()) ||
                 lastMessage.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  void _openChatScreen(Map<String, dynamic> message) {
    // TODO: Navigate to individual chat screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${message['senderName']}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _messages.where((msg) => !msg['isRead']).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Messages',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement compose new message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Compose new message feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(FontAwesomeIcons.penToSquare, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterMessages,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          
          // Messages List
          Expanded(
            child: _filteredMessages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredMessages.length,
                    itemBuilder: (context, index) {
                      final message = _filteredMessages[index];
                      return _buildMessageTile(message);
                    },
                  ),
          ),
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
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              FontAwesomeIcons.commentSlash,
              color: Colors.grey.shade400,
              size: 32,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No messages found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your conversations will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> message) {
    final isUnread = !message['isRead'];
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isUnread ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: message['avatar'] != null
                  ? NetworkImage(message['avatar'])
                  : null,
              child: message['avatar'] == null
                  ? Icon(
                      FontAwesomeIcons.user,
                      color: Colors.grey.shade500,
                      size: 18,
                    )
                  : null,
            ),
            if (isUnread)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message['senderName'],
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTimestamp(message['timestamp']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              message['senderRole'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              message['lastMessage'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Icon(
          FontAwesomeIcons.chevronRight,
          color: Colors.grey.shade400,
          size: 14,
        ),
        onTap: () => _openChatScreen(message),
      ),
    );
  }
}
