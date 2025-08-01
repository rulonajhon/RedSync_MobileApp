import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'educational_topics_screen.dart';
import 'educational_data_service.dart';

class EducationalResourcesScreen extends StatefulWidget {
  const EducationalResourcesScreen({super.key});

  @override
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Educational Resources',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.redAccent,
                    ),
                  ),
                  Text('Free Online/Offline Resources'),
                ],
              ),

              // TODO: Add a search bar here if needed
              SizedBox(height: 15),

              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final color = EducationalDataService.getColorFromString(
                      category['color'],
                    );
                    final topics = topicsData[category['title']] ?? [];

                    return Column(
                      children: [
                        ActionList(
                          listTitle: category['title'],
                          listIcon: _getIconData(category['icon']),
                          listIconColor: color,
                          listSubtitle: '${topics.length} Topics',
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
                        ),
                        SizedBox(height: 10),
                      ],
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
      default:
        return FontAwesomeIcons.book;
    }
  }
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
}
