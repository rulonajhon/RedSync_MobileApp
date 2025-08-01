import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'educational_content_screen.dart';

class EducationalTopicsScreen extends StatelessWidget {
  final String categoryTitle;
  final String categoryIcon;
  final Color categoryColor;
  final List<Map<String, dynamic>> topics;

  const EducationalTopicsScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.categoryColor,
    required this.topics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
        backgroundColor: categoryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      _getIconData(categoryIcon),
                      size: 48,
                      color: categoryColor,
                    ),
                    SizedBox(height: 12),
                    Text(
                      categoryTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${topics.length} topics available',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Topics List
              Expanded(
                child: ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getIconData(topic['icon']),
                            color: categoryColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          topic['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              topic['description'],
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${topic['readTime']} min read',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  topic['difficulty'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: categoryColor,
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EducationalContentScreen(
                                topic: topic,
                                categoryColor: categoryColor,
                              ),
                            ),
                          );
                        },
                      ),
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'dna':
        return FontAwesomeIcons.dna;
      case 'syringe':
        return FontAwesomeIcons.syringe;
      case 'notesMedical':
        return FontAwesomeIcons.notesMedical;
      case 'triangleExclamation':
        return FontAwesomeIcons.triangleExclamation;
      case 'users':
        return FontAwesomeIcons.users;
      case 'truckMedical':
        return FontAwesomeIcons.truckMedical;
      case 'bookOpenReader':
        return FontAwesomeIcons.bookOpenReader;
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
}
