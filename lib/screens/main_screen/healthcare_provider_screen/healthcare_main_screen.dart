import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hemophilia_manager/screens/main_screen/healthcare_provider_screen/healthcare_dashboard.dart';
import 'package:hemophilia_manager/screens/main_screen/healthcare_provider_screen/healthcare_patients_list.dart';
<<<<<<< HEAD
=======
import 'package:hemophilia_manager/screens/main_screen/healthcare_provider_screen/healthcare_messages_screen.dart';
>>>>>>> cbcb0a1 (New Updated File)

class HealthcareMainScreen extends StatefulWidget {
  const HealthcareMainScreen({super.key});

  @override
  State<HealthcareMainScreen> createState() => _HealthcareMainScreenState();
}

class _HealthcareMainScreenState extends State<HealthcareMainScreen> {
  int _currentIndex = 0;

  // BOTTOM NAVIGATION BAR ICONS
  final iconList = <IconData>[
    Icons.dashboard,
    FontAwesomeIcons.peopleGroup,
<<<<<<< HEAD
=======
    FontAwesomeIcons.message,
>>>>>>> cbcb0a1 (New Updated File)
  ];

  // LIST OF DISPLAYED SCREENS
  final List<Widget> _screens = [
    const HealthcareDashboard(),
    const HealthcarePatientsList(),
<<<<<<< HEAD
=======
    const HealthcareMessagesScreen(),
>>>>>>> cbcb0a1 (New Updated File)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _currentIndex,
        notchSmoothness: NotchSmoothness.softEdge,
        activeColor: Colors.redAccent,
        inactiveColor: Colors.blueGrey,
        gapLocation: GapLocation.none,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
