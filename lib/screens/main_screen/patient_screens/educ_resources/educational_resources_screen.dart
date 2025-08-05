import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
<<<<<<< HEAD
=======
import 'educational_topics_screen.dart';
import 'educational_data_service.dart';
>>>>>>> cbcb0a1 (New Updated File)

class EducationalResourcesScreen extends StatefulWidget {
  const EducationalResourcesScreen({super.key});

  @override
<<<<<<< HEAD
  State<EducationalResourcesScreen> createState() => _EducationalResourcesScreenState();
}

class _EducationalResourcesScreenState extends State<EducationalResourcesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
=======
  State<EducationalResourcesScreen> createState() =>
      _EducationalResourcesScreenState();
}

class _EducationalResourcesScreenState
    extends State<EducationalResourcesScreen> {
  final List<Map<String, dynamic>> categories =
      EducationalDataService.getCategoryData();
  final Map<String, List<Map<String, dynamic>>> topicsData =
      EducationalDataService.getEducationalTopics();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: Column(
>>>>>>> cbcb0a1 (New Updated File)
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Educational Resources',
<<<<<<< HEAD
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.redAccent),
                  ),
                  Text('Free Online/Offline Resources'),
                ],
              ),

              // TODO: Add a search bar here if needed
        
              SizedBox(height: 15),
        
              Expanded(
                child: ListView(
                  children: [
                    ActionList(
                      listTitle: 'Understanding Hemophilia',
                      listIcon: FontAwesomeIcons.dna,
                      listIconColor: Colors.deepPurple,
                      listSubtitle: '5 Topics',
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    ActionList(
                      listTitle: 'Treatment & Management',
                      listIcon: FontAwesomeIcons.syringe,
                      listIconColor: Colors.green,
                      listSubtitle: '7 Topics',
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    ActionList(
                      listTitle: 'Self-Care & Monitoring',
                      listIcon: FontAwesomeIcons.notesMedical,
                      listIconColor: Colors.blueAccent,
                      listSubtitle: '15 Topics',
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    ActionList(
                      listTitle: 'Common Complications',
                      listIcon: FontAwesomeIcons.triangleExclamation,
                      listIconColor: Colors.redAccent,
                      listSubtitle: '10 Topics',
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    ActionList(
                      listTitle: 'For Parents and Caregivers',
                      listIcon: FontAwesomeIcons.users,
                      listIconColor: Colors.orangeAccent,
                      listSubtitle: '10 Topics',
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    ActionList(
                      listTitle: 'Emergency Instructions',
                      listIcon: FontAwesomeIcons.truckMedical,
                      listIconColor: Colors.pinkAccent,
                      listSubtitle: '10 Topics',
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    ActionList(
                      listTitle: 'Learning Material for all Ages',
                      listIcon: FontAwesomeIcons.bookOpenReader,
                      listIconColor: Colors.yellow,
                      listSubtitle: '10 Topics',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
=======
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Learn about hemophilia and stay informed',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Categories list
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(20),
                itemCount: categories.length,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final color = EducationalDataService.getColorFromString(
                    category['color'],
                  );
                  final topics = topicsData[category['title']] ?? [];

                  return _buildCategoryItem(category, color, topics);
                },
              ),
            ),
          ],
>>>>>>> cbcb0a1 (New Updated File)
        ),
      ),
    );
  }
<<<<<<< HEAD
}

class ActionList extends StatelessWidget {
  final String listTitle;
  final String listSubtitle;
  final IconData listIcon;
  final Color listIconColor;
  final VoidCallback onTap;

  const ActionList({
    super.key,
    required this.listTitle,
    required this.listIcon,
    required this.listSubtitle,
    required this.onTap,
    required this.listIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(listIcon, color: listIconColor),
      title: Text(listTitle, style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(listSubtitle),
      onTap: onTap,
      // ignore: deprecated_member_use
      tileColor: listIconColor.withOpacity(0.15),
    );
  }
=======

  Widget _buildCategoryItem(
    Map<String, dynamic> category,
    Color color,
    List<Map<String, dynamic>> topics,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EducationalTopicsScreen(
              categoryTitle: category['title'],
              categoryIcon: category['icon'],
              categoryColor: color,
              topics: topics,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getIconData(category['icon']),
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),

            // Category Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    category['description'] ?? 'Explore this category',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),

                  // Topic count badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${topics.length} topics',
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                FontAwesomeIcons.chevronRight,
                color: color,
                size: 14,
              ),
            ),
          ],
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
      default:
        return FontAwesomeIcons.book;
    }
  }
>>>>>>> cbcb0a1 (New Updated File)
}
