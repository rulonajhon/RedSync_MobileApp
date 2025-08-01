import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EducationalContentScreen extends StatefulWidget {
  final Map<String, dynamic> topic;
  final Color categoryColor;

  const EducationalContentScreen({
    super.key,
    required this.topic,
    required this.categoryColor,
  });

  @override
  State<EducationalContentScreen> createState() =>
      _EducationalContentScreenState();
}

class _EducationalContentScreenState extends State<EducationalContentScreen> {
  bool _isBookmarked = false;
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic['title'], style: TextStyle(fontSize: 18)),
        backgroundColor: widget.categoryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isBookmarked
                        ? 'Added to bookmarks'
                        : 'Removed from bookmarks',
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'font_size') {
                _showFontSizeDialog();
              } else if (value == 'share') {
                _shareContent();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'font_size',
                child: Row(
                  children: [
                    Icon(Icons.text_fields, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text('Font Size'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.categoryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconData(widget.topic['icon']),
                          color: widget.categoryColor,
                          size: 32,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.topic['title'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: widget.categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.schedule,
                          '${widget.topic['readTime']} min',
                        ),
                        SizedBox(width: 8),
                        _buildInfoChip(Icons.star, widget.topic['difficulty']),
                        SizedBox(width: 8),
                        _buildInfoChip(Icons.visibility, 'Medical Review'),
                      ],
                    ),
                    if (widget.topic['description'] != null) ...[
                      SizedBox(height: 16),
                      Text(
                        widget.topic['description'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Content Sections
              ...widget.topic['content'].map<Widget>((section) {
                return _buildContentSection(section);
              }).toList(),

              SizedBox(height: 32),

              // Additional Resources
              if (widget.topic['additionalResources'] != null) ...[
                _buildSectionTitle('Additional Resources'),
                SizedBox(height: 16),
                ...widget.topic['additionalResources'].map<Widget>((resource) {
                  return _buildResourceCard(resource);
                }).toList(),
                SizedBox(height: 24),
              ],

              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.categoryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: widget.categoryColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: widget.categoryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: widget.categoryColor,
      ),
    );
  }

  Widget _buildContentSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section['title'] != null) ...[
          _buildSectionTitle(section['title']),
          SizedBox(height: 16),
        ],
        if (section['content'] != null) ...[
          Text(
            section['content'],
            style: TextStyle(
              fontSize: _fontSize,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
        ],
        if (section['bulletPoints'] != null) ...[
          ...section['bulletPoints'].map<Widget>((point) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8, right: 12),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.6,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 20),
        ],
        if (section['warning'] != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section['warning'],
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getResourceIcon(resource['type']),
          color: widget.categoryColor,
        ),
        title: Text(
          resource['title'],
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(resource['description']),
        trailing: Icon(Icons.open_in_new, size: 16),
        onTap: () {
          // Handle resource tap
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${resource['title']}...'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Actions'),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle quiz
                  _showComingSoonDialog('Interactive Quiz');
                },
                icon: Icon(Icons.quiz, color: Colors.white),
                label: Text('Take Quiz', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.categoryColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Handle notes
                  _showComingSoonDialog('Personal Notes');
                },
                icon: Icon(Icons.note_add, color: widget.categoryColor),
                label: Text(
                  'Add Notes',
                  style: TextStyle(color: widget.categoryColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.categoryColor),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'heart':
        return FontAwesomeIcons.heart;
      case 'droplet':
        return FontAwesomeIcons.droplet;
      case 'microscope':
        return FontAwesomeIcons.microscope;
      case 'pills':
        return FontAwesomeIcons.pills;
      case 'userDoctor':
        return FontAwesomeIcons.userDoctor;
      case 'hospital':
        return FontAwesomeIcons.hospital;
      case 'baby':
        return FontAwesomeIcons.baby;
      case 'phone':
        return FontAwesomeIcons.phone;
      case 'book':
        return FontAwesomeIcons.book;
      case 'gamepad':
        return FontAwesomeIcons.gamepad;
      default:
        return FontAwesomeIcons.book;
    }
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_outline;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'website':
        return Icons.web;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.link;
    }
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Adjust text size for better readability'),
            SizedBox(height: 16),
            Slider(
              value: _fontSize,
              min: 12.0,
              max: 20.0,
              divisions: 8,
              label: _fontSize.round().toString(),
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _shareContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Coming Soon'),
        content: Text('$feature feature will be available in the next update!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
