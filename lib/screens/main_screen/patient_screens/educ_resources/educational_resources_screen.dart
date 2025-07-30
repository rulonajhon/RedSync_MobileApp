import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EducationalResourcesScreen extends StatefulWidget {
  const EducationalResourcesScreen({super.key});

  @override
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Educational Resources',
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
        ),
      ),
    );
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
