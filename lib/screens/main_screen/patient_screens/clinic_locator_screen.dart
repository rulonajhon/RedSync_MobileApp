import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClinicLocatorScreen extends StatefulWidget {
  const ClinicLocatorScreen({super.key});

  @override
  State<ClinicLocatorScreen> createState() => _ClinicLocatorScreenState();
}

class _ClinicLocatorScreenState extends State<ClinicLocatorScreen> {
  final List<Map<String, String>> clinics = [
    {
      'name': 'Ms. Miltordeliza B. Gonzaga, MD',
      'address':
          'Room 601, Davao Doctor’s Hospital, 115 E. Quirino Avenue, Davao City, Davao Del Sur',
    },
    {
      'name': 'Dr. Heide Abdurahman',
      'address':
          'Brokenshire Hospital, Madapo Hills, Poblacion District, Davao City, 8000 Davao Del Sur',
    },
    {
      'name': 'Davao Doctor’s Hospital',
      'address':
          'Room 601, Medical Towers Davao Doctor’s Hospital, 115 E. Quirino Avenue, Davao City, Davao Del Sur',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinic Locator',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.redAccent,
                        ),
                      ),
                      Text('Find nearby clinics'),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      FontAwesomeIcons.filter,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: Text(
                    'Map Placeholder',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Hospital Lists',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              SizedBox(height: 2),
              Text(
                'Near you',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: clinics.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final clinic = clinics[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        title: Text(
                          clinic['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          clinic['address']!,
                          style: TextStyle(fontSize: 13),
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () {
                          // Optionally animate to marker or show details
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
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        label: Text('Find?'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: Icon(FontAwesomeIcons.magnifyingGlassLocation),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'What are you looking for?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 18),
                    ListTile(
                      // put a background color for the icon
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FontAwesomeIcons.syringe,
                          color: Colors.white,
                        ),
                      ),
                      title: Text('Drug Outlet'),
                      subtitle: Text(
                        'Find drug outlets near you',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Filter map/list for drug outlets
                      },
                    ),
                    Divider(height: 1, color: Colors.black12),
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FontAwesomeIcons.hospital,
                          color: Colors.white,
                        ),
                      ),
                      title: Text('Nearby Treatment Center'),
                      subtitle: Text(
                        'Find treatment centers near you',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Filter map/list for clinics
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// TODO: Implement a screen change when the user selects a clinic or drug outlet
// Drug Outlet and Clinic Locator
