import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data - replace with actual data later
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'authorName': 'Sarah M.',
      'authorRole': 'Patient',
      'content': 'Just wanted to share that I had my first successful self-infusion today! Thanks to everyone who shared their tips and encouragement. 💪',
      'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      'likes': 12,
      'comments': 5,
      'isLiked': false,
    },
    {
      'id': '2',
      'authorName': 'Dr. Johnson',
      'authorRole': 'Hematologist',
      'content': 'Reminder: Winter weather can sometimes affect bleeding episodes. Make sure to stay warm and keep your factor replacement handy during cold months. ❄️',
      'timestamp': DateTime.now().subtract(Duration(hours: 5)),
      'likes': 23,
      'comments': 8,
      'isLiked': true,
    },
    {
      'id': '3',
      'authorName': 'Mike Chen',
      'authorRole': 'Patient',
      'content': 'Has anyone tried the new factor concentrate that was recently approved? I\'m considering switching and would love to hear your experiences.',
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
      'likes': 7,
      'comments': 12,
      'isLiked': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Community',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Search feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 18),
          ),
          IconButton(
            onPressed: _showCreatePostDialog,
            icon: Icon(FontAwesomeIcons.plus, size: 18),
          ),
          SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.redAccent,
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: [
            Tab(text: 'Feed'),
            Tab(text: 'Groups'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildFeedTab(),
            _buildGroupsTab(),
            _buildEventsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostItem(_posts[index]);
        },
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                child: Text(
                  post['authorName'][0],
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['authorName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post['authorRole'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _formatTimestamp(post['timestamp']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showPostOptions(post),
                icon: Icon(FontAwesomeIcons.ellipsis, size: 16),
                color: Colors.grey.shade600,
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Post Content
          Text(
            post['content'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Post Actions
          Row(
            children: [
              _buildActionButton(
                icon: post['isLiked'] ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                label: '${post['likes']}',
                color: post['isLiked'] ? Colors.red : Colors.grey.shade600,
                onTap: () => _toggleLike(post),
              ),
              SizedBox(width: 24),
              _buildActionButton(
                icon: FontAwesomeIcons.comment,
                label: '${post['comments']}',
                color: Colors.grey.shade600,
                onTap: () => _showComments(post),
              ),
              SizedBox(width: 24),
              _buildActionButton(
                icon: FontAwesomeIcons.share,
                label: 'Share',
                color: Colors.grey.shade600,
                onTap: () => _sharePost(post),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildComingSoonCard(
              icon: FontAwesomeIcons.users,
              title: 'Support Groups',
              subtitle: 'Connect with others in your area or condition-specific groups',
            ),
            SizedBox(height: 16),
            _buildComingSoonCard(
              icon: FontAwesomeIcons.commentDots,
              title: 'Discussion Forums',
              subtitle: 'Join topic-based discussions and ask questions',
            ),
            SizedBox(height: 16),
            _buildComingSoonCard(
              icon: FontAwesomeIcons.userDoctor,
              title: 'Expert Q&A',
              subtitle: 'Get answers from healthcare professionals',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildComingSoonCard(
              icon: FontAwesomeIcons.calendar,
              title: 'Community Events',
              subtitle: 'Local meetups, conferences, and support events',
            ),
            SizedBox(height: 16),
            _buildComingSoonCard(
              icon: FontAwesomeIcons.chalkboardUser,
              title: 'Educational Webinars',
              subtitle: 'Learn from experts about hemophilia management',
            ),
            SizedBox(height: 16),
            _buildComingSoonCard(
              icon: FontAwesomeIcons.handHoldingHeart,
              title: 'Fundraising Events',
              subtitle: 'Participate in awareness and fundraising activities',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: Colors.redAccent, size: 24),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Coming Soon',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              Icon(
                FontAwesomeIcons.penToSquare,
                size: 48,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16),
              Text(
                'Post Creation Coming Soon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You\'ll soon be able to share updates, ask questions, and connect with the community.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostOptions(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(FontAwesomeIcons.bookmark, color: Colors.blue),
              title: Text('Save Post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Feature coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.flag, color: Colors.orange),
              title: Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Feature coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _toggleLike(Map<String, dynamic> post) {
    setState(() {
      post['isLiked'] = !post['isLiked'];
      if (post['isLiked']) {
        post['likes']++;
      } else {
        post['likes']--;
      }
    });
  }

  void _showComments(Map<String, dynamic> post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comments feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sharePost(Map<String, dynamic> post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshFeed() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feed refreshed'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
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
}
