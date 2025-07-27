import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmergencyFab extends StatefulWidget {
  const EmergencyFab({super.key});

  @override
  State<EmergencyFab> createState() => _EmergencyFabState();
}

class _EmergencyFabState extends State<EmergencyFab> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SizedBox(
                height: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Is there an emergency?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    Expanded(
                      child: ListView(
                        children: [
                          ListTile(
                            leading: Icon(Icons.phone, color: Colors.redAccent),
                            title: Text('Call Emergency Contact'),
                            onTap: () {
                              // Implement call emergency contact
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.phone, color: Colors.redAccent),
                            title: Text('Call Care Provider'),
                            onTap: () {
                              // Implement call care provider
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              FontAwesomeIcons.houseChimneyMedical,
                              color: Colors.blueAccent,
                            ),
                            title: Text('Find Nearest Hospital'),
                            onTap: () {
                              // Implement find nearest hospital
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              FontAwesomeIcons.bookMedical,
                              color: Colors.green,
                            ),
                            title: Text('Bleed Guide'),
                            onTap: () {
                              // Implement bleed guide
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              FontAwesomeIcons.bookMedical,
                              color: Colors.amber,
                            ),
                            title: Text('Infusion Guide'),
                            onTap: () {
                              // Implement infusion guide
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      foregroundColor: Colors.white,
      backgroundColor: Colors.red,
      tooltip: 'Emergency',
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Icon(FontAwesomeIcons.triangleExclamation),
    );
  }
}
