import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // Add a test notification if none exist
    _addTestNotificationIfNeeded();
  }

  Future<void> _addTestNotificationIfNeeded() async {
    if (uid.isNotEmpty) {
      try {
        // Check if any notifications exist
        final snapshot = await FirebaseFirestore.instance
            .collection('notifications')
            .where('uid', isEqualTo: uid)
            .limit(1)
            .get();
        
        // If no notifications exist, add a welcome message
        if (snapshot.docs.isEmpty) {
          await _firestoreService.createNotification(
            uid, 
            'Welcome to BleedWatch! Your notifications will appear here.'
          );
        }
      } catch (e) {
        print('Error checking notifications: $e');
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (uid.isNotEmpty) {
      await _firestoreService.markAllNotificationsAsRead(uid);
    }
  }

  Future<void> _deleteAll() async {
    if (uid.isNotEmpty) {
      await _firestoreService.deleteAllNotifications(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (outerContext) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (!outerContext.mounted) return;
                showModalBottomSheet<void>(
                  context: outerContext,
                  builder: (BuildContext context) {
                    return Container(
                      color: Colors.white,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            leading: Icon(Icons.mark_email_read),
                            title: Text('Mark All as Read'),
                            onTap: () async {
                              await _markAllAsRead();
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete All'),
                            onTap: () async {
                              await _deleteAll();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              icon: Icon(FontAwesomeIcons.ellipsisVertical),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TODAY'),
              SizedBox(height: 10),
              Expanded(
                child: uid.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('notifications')
                            .where('uid', isEqualTo: uid)
                            .snapshots(), // Remove orderBy to avoid index requirement
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            print('Firestore error: ${snapshot.error}');
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, size: 48, color: Colors.red),
                                  SizedBox(height: 16),
                                  Text('Error loading notifications'),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => setState(() {}),
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];
                          
                          // Sort docs on client side by timestamp if available
                          docs.sort((a, b) {
                            final dataA = a.data() as Map<String, dynamic>;
                            final dataB = b.data() as Map<String, dynamic>;
                            final timestampA = dataA['timestamp'] as Timestamp?;
                            final timestampB = dataB['timestamp'] as Timestamp?;
                            
                            if (timestampA != null && timestampB != null) {
                              return timestampB.compareTo(timestampA); // Descending order
                            }
                            return 0;
                          });
                          
                          if (docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('No notifications yet'),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _firestoreService.createNotification(
                                        uid, 
                                        'Test notification created at ${DateTime.now().toString().substring(0, 16)}'
                                      );
                                    },
                                    child: Text('Add Test Notification'),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => SizedBox(height: 5),
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              return NotificationList(
                                text: data['text'] ?? 'No message',
                                time: data['timestamp'] != null
                                    ? _formatTime(data['timestamp'])
                                    : 'No time',
                                read: data['read'] ?? false,
                                onTap: () async {
                                  if (!data['read']) {
                                    await _firestoreService.markNotificationAsRead(doc.id);
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final dt = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${dt.month}/${dt.day}/${dt.year}';
    }
    return '';
  }
}

class NotificationList extends StatelessWidget {
  final String text;
  final String time;
  final bool read;
  final VoidCallback? onTap;

  const NotificationList({
    super.key,
    required this.text,
    required this.time,
    required this.read,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: read ? Colors.grey.shade200 : Colors.blueGrey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.blue,
          ),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(text),
        subtitle: Text(time),
        trailing: read ? null : Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
