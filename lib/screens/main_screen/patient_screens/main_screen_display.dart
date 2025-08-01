import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/clinic_locator_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/dashboard_screens.dart/dashboard_screen.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/educ_resources/educational_resources_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hemophilia_manager/screens/registration/authentication_landing_screen.dart';
import 'package:hemophilia_manager/auth/auth.dart';

class MainScreenDisplay extends StatefulWidget {
  const MainScreenDisplay({super.key});

  @override
  State<MainScreenDisplay> createState() => _MainScreenDisplayState();
}

class _MainScreenDisplayState extends State<MainScreenDisplay> {
  int _currentIndex = 0;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // BOTTOM NAVIGATION BAR ICONS
  final iconList = <IconData>[
    FontAwesomeIcons.house,
    FontAwesomeIcons.book,
    FontAwesomeIcons.robot,
    FontAwesomeIcons.houseChimneyMedical,
  ];

  // LIST OF DISPLAYED SCREENS (removed ChatbotScreen from here)
  final List<Widget> _screens = [
    Dashboard(),
    EducationalResourcesScreen(),
    ClinicLocatorScreen(), // Moved clinic locator to index 2
  ];

  Future<void> _logout() async {
    try {
      print('DEBUG - Starting logout process');

      // Check if user is a guest
      final isGuest = await _secureStorage.read(key: 'isGuest');

      // Sign out from Firebase Auth (this handles both regular and anonymous users)
      try {
        final authService = AuthService();
        await authService.signOut();
        print('DEBUG - Signed out from Firebase Auth');
      } catch (authError) {
        print('DEBUG - Firebase Auth signout error (continuing): $authError');
      }

      // Clear all secure storage data explicitly
      await _secureStorage.delete(key: 'isLoggedIn');
      await _secureStorage.delete(key: 'userRole');
      await _secureStorage.delete(key: 'userUid');
      await _secureStorage.delete(key: 'saved_email');
      await _secureStorage.delete(key: 'saved_password');
      await _secureStorage.delete(key: 'remember_me');
      await _secureStorage.delete(key: 'isGuest');

      // Also use deleteAll as backup
      await _secureStorage.deleteAll();

      print('DEBUG - Cleared all secure storage during logout');

      if (!mounted) return;

      // Navigate to authentication screen and clear all routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthenticationLandingScreen()),
        (route) => false,
      );

      print('DEBUG - Navigated to authentication screen');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isGuest == 'true'
                  ? 'Guest session ended'
                  : 'Logged out successfully',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      // Even if there's an error, still navigate to authentication screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AuthenticationLandingScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 2) {
      // Chatbot icon - open in separate screen
      Navigator.pushNamed(context, '/chatbot');
    } else {
      // For other tabs, handle normally but adjust index for removed chatbot
      int adjustedIndex = index;
      if (index > 2) {
        adjustedIndex = index - 1; // Adjust for removed chatbot screen
      }
      setState(() {
        _currentIndex = adjustedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Image.asset('assets/images/app_logo.png', width: 60),

        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              // ignore: deprecated_member_use
              backgroundColor: Colors.redAccent.withOpacity(0.15),
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.solidBell,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              // ignore: deprecated_member_use
              backgroundColor: Colors.redAccent.withOpacity(0.15),
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.solidMessage,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/messages');
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: CircleAvatar(
                radius: 20,
                // backgroundImage: AssetImage(''),
                // TODO: Must put image here coming from firebase storage
                child: Icon(
                  FontAwesomeIcons.solidUser,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton.large(
        heroTag: "main_screen_fab", // Unique tag to avoid conflicts
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) {
              return SafeArea(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        _ActionTile(
                          label: 'Log New Bleed',
                          icon: FontAwesomeIcons.droplet,
                          bgColor: Color(0xFFE57373),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/log_bleed');
                          },
                        ),
                        SizedBox(height: 5),
                        _ActionTile(
                          label: 'Log New Infusion',
                          icon: FontAwesomeIcons.syringe,
                          bgColor: Color(0xFFBA68C8),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/log_infusion');
                          },
                        ),
                        SizedBox(height: 5),
                        _ActionTile(
                          label: 'Schedule Medication',
                          icon: FontAwesomeIcons.pills,
                          bgColor: Color(0xFF64B5F6),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              '/schedule_medication',
                            );
                          },
                        ),
                        SizedBox(height: 5),
                        _ActionTile(
                          label: 'Dosage Calculator',
                          icon: FontAwesomeIcons.calculator,
                          bgColor: Color(0xFF81C784),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/dose_calculator');
                          },
                        ),
                        SizedBox(height: 5),
                        _ActionTile(
                          label: 'Log History',
                          icon: FontAwesomeIcons.clockRotateLeft,
                          bgColor: Color(0xFFFFB74D),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/log_history');
                          },
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.redAccent,
                              width: 1.5,
                            ),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            leading: Icon(
                              FontAwesomeIcons.plus,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            title: Text(
                              'Add Care Provider',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/care_provider');
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        backgroundColor: Colors.redAccent,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _currentIndex >= 2
            ? _currentIndex + 1
            : _currentIndex, // Adjust active index display
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        height: 60,
        leftCornerRadius: 16,
        rightCornerRadius: 16,
        backgroundColor: Colors.white,
        activeColor: Colors.redAccent,
        inactiveColor: Colors.blueGrey,
        onTap: _onBottomNavTap, // Use custom tap handler
      ),
    );
  }
}

// Helper widget for list tiles
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color bgColor;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: onTap,
      ),
    );
  }
}
