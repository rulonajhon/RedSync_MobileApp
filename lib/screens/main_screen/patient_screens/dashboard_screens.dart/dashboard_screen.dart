import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hemophilia_manager/services/firestore.dart';
import 'package:hemophilia_manager/screens/main_screen/patient_screens/dashboard_screens.dart/emergency_fab.dart';
import 'package:hive/hive.dart';
import '../log_bleed.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  String _userName = '';
  bool _isLoading = true;
  List<BleedLog> _recentBleeds = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRecentBleeds();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await _firestoreService.getUser(user.uid);
        if (userData != null) {
          setState(() {
            _userName = userData['name'] ?? 'User';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecentBleeds() async {
    try {
      final box = await Hive.openBox<BleedLog>('bleed_logs');
      final bleeds = box.values.take(3).toList();
      setState(() => _recentBleeds = bleeds);
    } catch (e) {
      print('Error loading recent bleeds: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeOfDay = _getTimeOfDay();
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserData();
          await _loadRecentBleeds();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getTimeIcon(),
                        color: Colors.redAccent,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$timeOfDay${_isLoading ? '!' : ', $_userName!'}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Here\'s your health summary for today',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),

                // Quick Stats Section
                _buildQuickStats(),
                SizedBox(height: 32),

                // Reminders Section
                _buildSection(
                  title: 'Today\'s Reminders',
                  icon: FontAwesomeIcons.clock,
                  children: [
                    _buildReminderItem(
                      icon: FontAwesomeIcons.syringe,
                      title: 'Infusion Reminder',
                      subtitle: 'No infusion scheduled today',
                      iconColor: Colors.purple,
                    ),
                    SizedBox(height: 12),
                    _buildReminderItem(
                      icon: FontAwesomeIcons.pills,
                      title: 'Medication',
                      subtitle: 'All medications taken',
                      iconColor: Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 32),

                // Recent Activity Section
                _buildSection(
                  title: 'Recent Activity',
                  icon: FontAwesomeIcons.clockRotateLeft,
                  children: [
                    if (_recentBleeds.isEmpty)
                      _buildEmptyState(
                        icon: FontAwesomeIcons.heart,
                        title: 'No recent activity',
                        subtitle: 'Your logged activities will appear here',
                      )
                    else
                      ..._recentBleeds.map((bleed) => Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: _buildActivityItem(
                          icon: FontAwesomeIcons.droplet,
                          title: 'Bleed Logged',
                          subtitle: '${bleed.bodyRegion} • ${bleed.severity}',
                          time: bleed.date,
                          iconColor: Colors.red,
                        ),
                      )),
                  ],
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: EmergencyFab(),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatContainer(
            icon: FontAwesomeIcons.droplet,
            value: '${_recentBleeds.length}',
            label: 'Recent Bleeds',
            color: Colors.red,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatContainer(
            icon: FontAwesomeIcons.syringe,
            value: '0',
            label: 'This Week',
            color: Colors.purple,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatContainer(
            icon: FontAwesomeIcons.calendar,
            value: '7',
            label: 'Days Active',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatContainer({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Colors.grey.shade700),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return FontAwesomeIcons.sun;
    if (hour < 17) return FontAwesomeIcons.cloudSun;
    return FontAwesomeIcons.moon;
  }
}
