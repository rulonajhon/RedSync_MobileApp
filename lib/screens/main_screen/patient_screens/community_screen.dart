import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../services/community_service.dart';
import '../../new_post_screen.dart';
import '../../comments_screen.dart';
import '../../post_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityService _communityService = CommunityService();

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
        title: Text('Community', style: TextStyle(fontWeight: FontWeight.w600)),
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
          // Temporary debug button to add test data
          IconButton(
            onPressed: _addTestData,
            icon: Icon(FontAwesomeIcons.flask, size: 18),
            tooltip: 'Add test posts',
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
          children: [_buildFeedTab(), _buildGroupsTab(), _buildEventsTab()],
        ),
      ),
    );
  }

  Widget _buildFeedTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _communityService.getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.exclamationTriangle,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Error loading posts',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.comments, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Be the first to share something!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _createNewPost,
                  icon: Icon(FontAwesomeIcons.plus),
                  label: Text('Create Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshFeed,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostItemWithRealTimeData(posts[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildPostItemWithRealTimeData(Map<String, dynamic> post) {
    final postId = post['id'];

    return StreamBuilder<Map<String, dynamic>>(
      stream: _communityService.getLikesStream(postId),
      builder: (context, likesSnapshot) {
        if (!likesSnapshot.hasData) {
          return _buildPostItemStatic(post, 0, 0, false);
        }

        final likesData = likesSnapshot.data!;
        final likesCount = likesData['count'] ?? 0;
        final isLiked = likesData['isLiked'] ?? false;

        return StreamBuilder<int>(
          stream: _communityService.getCommentsCountStream(postId),
          builder: (context, commentsSnapshot) {
            final commentsCount = commentsSnapshot.data ?? 0;

            return _buildPostItemStatic(
              post,
              likesCount,
              commentsCount,
              isLiked,
            );
          },
        );
      },
    );
  }

  Widget _buildPostItemStatic(
    Map<String, dynamic> post,
    int likesCount,
    int commentsCount,
    bool isLiked,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: Container(
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: post['authorRole'] == 'Healthcare Provider'
                                  ? Colors.blue.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              post['authorRole'],
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    post['authorRole'] == 'Healthcare Provider'
                                    ? Colors.blue.shade700
                                    : Colors.green.shade700,
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

            // Post Actions with real-time data
            Row(
              children: [
                _buildActionButton(
                  icon: isLiked
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  label: '$likesCount',
                  color: isLiked ? Colors.red : Colors.grey.shade600,
                  onTap: () => _toggleLike(post),
                ),
                SizedBox(width: 24),
                _buildActionButton(
                  icon: FontAwesomeIcons.comment,
                  label: '$commentsCount',
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
              subtitle:
                  'Connect with others in your area or condition-specific groups',
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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

  void _showCreatePostDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewPostScreen()),
    );

    if (result == true) {
      // Post was created successfully, the stream will automatically update
      setState(() {});
    }
  }

  Future<void> _createNewPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewPostScreen()),
    );

    if (result == true) {
      // Post was created successfully, the stream will automatically update
      setState(() {});
    }
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
              leading: Icon(FontAwesomeIcons.flag, color: Colors.orange),
              title: Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                _reportPost(post);
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLike(Map<String, dynamic> post) async {
    try {
      await _communityService.toggleLike(post['id']);
      // The stream will automatically update the UI
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle like: $e')));
    }
  }

  void _showComments(Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CommentsScreen(postId: post['id'], postContent: post['content']),
      ),
    );
  }

  Future<void> _sharePost(Map<String, dynamic> post) async {
    try {
      await _communityService.sharePost(postId: post['id']);

      // Show native share dialog
      final shareText = '${post['content']}\n\nShared from RedSync Community';
      await _showShareDialog(shareText);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post shared successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share post: $e')));
    }
  }

  Future<void> _showShareDialog(String text) async {
    showModalBottomSheet(
      context: context,
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
                'Share Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(text, style: TextStyle(fontSize: 14)),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    icon: FontAwesomeIcons.copy,
                    label: 'Copy',
                    onTap: () {
                      // Copy to clipboard would go here
                      Navigator.pop(context);
                    },
                  ),
                  _buildShareOption(
                    icon: FontAwesomeIcons.envelope,
                    label: 'Email',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildShareOption(
                    icon: FontAwesomeIcons.shareNodes,
                    label: 'More',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: Colors.grey.shade700),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Future<void> _reportPost(Map<String, dynamic> post) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Why are you reporting this post?'),
            SizedBox(height: 16),
            ...[
              'Inappropriate content',
              'Spam',
              'Harassment',
              'False information',
              'Other',
            ].map(
              (reason) => ListTile(
                title: Text(reason),
                onTap: () => Navigator.pop(context, reason),
              ),
            ),
          ],
        ),
      ),
    );

    if (reason != null) {
      try {
        await _communityService.reportPost(postId: post['id'], reason: reason);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post reported successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to report post: $e')));
      }
    }
  }

  Future<void> _refreshFeed() async {
    // The stream will automatically refresh, just provide user feedback
    setState(() {});
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

  // Temporary method to add test data for demonstration
  Future<void> _addTestData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No user logged in')));
        return;
      }

      // Add test posts
      final posts = [
        {
          'content':
              'Just had my first successful self-infusion today! Thanks to everyone who shared their tips and encouragement. The community support here is amazing! 💪',
          'authorId': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(),
        },
        {
          'content':
              'Has anyone tried the new factor concentrate that was recently approved? I\'m considering switching and would love to hear your experiences and any tips you might have.',
          'authorId': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(),
        },
        {
          'content':
              'Sharing some tips for fellow patients: Remember to stay hydrated, rotate your injection sites, and don\'t hesitate to reach out to your healthcare team if you have concerns. We\'re all in this together! 🤝',
          'authorId': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(),
        },
      ];

      for (final post in posts) {
        await firestore.collection('community_posts').add(post);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Test posts added! Refresh to see them.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error adding test posts: $e')));
    }
  }
}
