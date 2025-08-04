import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/community_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper function to safely convert timestamp
  DateTime _safeTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is DateTime) return timestamp;
    if (timestamp.runtimeType.toString().contains('Timestamp')) {
      return timestamp.toDate();
    }
    return DateTime.now();
  }

  Future<void> _toggleLike(String postId) async {
    try {
      await _communityService.toggleLike(postId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle like: $e')));
    }
  }

  Future<void> _sharePost(String content) async {
    try {
      await _communityService.sharePost(postId: widget.post['id']);

      // Show native share dialog
      final shareText = '$content\n\nShared from RedSync Community';
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
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share Post',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(text, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    icon: FontAwesomeIcons.copy,
                    label: 'Copy',
                    onTap: () {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B0000).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: const Color(0xFF8B0000), size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await _communityService.addComment(
        postId: widget.post['id'],
        content: _commentController.text.trim(),
      );
      _commentController.clear();

      // Scroll to bottom to show the new comment
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B0000),
        title: const Text('Post', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Post Content Section
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post Header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(
                                  0xFF8B0000,
                                ).withOpacity(0.1),
                                child: Text(
                                  widget.post['authorName']?[0]
                                          ?.toUpperCase() ??
                                      'U',
                                  style: const TextStyle(
                                    color: Color(0xFF8B0000),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.post['authorName'] ??
                                          'Unknown User',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(
                                        _safeTimestamp(
                                          widget.post['timestamp'],
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Post Content
                          Text(
                            widget.post['content'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Action Buttons with Real-time Data
                          Row(
                            children: [
                              // Like Button with Stream
                              StreamBuilder<Map<String, dynamic>>(
                                stream: _communityService.getLikesStream(
                                  widget.post['id'],
                                ),
                                builder: (context, likesSnapshot) {
                                  final likesData = likesSnapshot.data ?? {};
                                  final likesCount = likesData['count'] ?? 0;
                                  return _buildActionButton(
                                    icon: Icons.thumb_up,
                                    label: likesCount.toString(),
                                    color: const Color(0xFF8B0000),
                                    onTap: () => _toggleLike(widget.post['id']),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),

                              // Comment Button with Stream
                              StreamBuilder<int>(
                                stream: _communityService
                                    .getCommentsCountStream(widget.post['id']),
                                builder: (context, commentsSnapshot) {
                                  final commentsCount =
                                      commentsSnapshot.data ?? 0;
                                  return _buildActionButton(
                                    icon: Icons.comment,
                                    label: commentsCount.toString(),
                                    color: Colors.blue,
                                    onTap: () {
                                      // Scroll to comments section
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position
                                            .maxScrollExtent,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 12),

                              // Share Button
                              _buildActionButton(
                                icon: Icons.share,
                                label: 'Share',
                                color: Colors.green,
                                onTap: () =>
                                    _sharePost(widget.post['content'] ?? ''),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Comments Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Comments List
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _communityService.getCommentsStream(
                            widget.post['id'],
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: Text(
                                    'Error loading comments: ${snapshot.error}',
                                  ),
                                ),
                              );
                            }

                            final comments = snapshot.data ?? [];

                            if (comments.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: Text(
                                    'No comments yet. Be the first to comment!',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: comments.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: const Color(
                                          0xFF8B0000,
                                        ).withOpacity(0.1),
                                        child: Text(
                                          comment['authorName']?[0]
                                                  ?.toUpperCase() ??
                                              'U',
                                          style: const TextStyle(
                                            color: Color(0xFF8B0000),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  comment['authorName'] ??
                                                      'Unknown User',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _formatTimestamp(
                                                    _safeTimestamp(
                                                      comment['timestamp'],
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment['content'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFF8B0000),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _addComment,
                    backgroundColor: const Color(0xFF8B0000),
                    mini: true,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
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
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
