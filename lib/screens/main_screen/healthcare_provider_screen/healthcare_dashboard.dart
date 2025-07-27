import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore.dart';

class HealthcareDashboard extends StatefulWidget {
  const HealthcareDashboard({super.key});

  @override
  State<HealthcareDashboard> createState() => _HealthcareDashboardState();
}

class _HealthcareDashboardState extends State<HealthcareDashboard> {
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final FirestoreService _firestoreService = FirestoreService();
  String _userName = 'Doctor';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      if (currentUid.isNotEmpty) {
        final userData = await _firestoreService.getUser(currentUid);
        if (userData != null && mounted) {
          setState(() {
            _userName = userData['name'] ?? 'Doctor';
          });
        }
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        toolbarHeight: 70,
        title: Image.asset('assets/images/app_logo.png', width: 60),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              // ignore: deprecated_member_use
              backgroundColor: Colors.redAccent.withOpacity(0.15),
              child: IconButton(
                icon: const Icon(FontAwesomeIcons.solidBell, color: Colors.redAccent),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
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
                backgroundImage: AssetImage('assets/avatar_placeholder.png'),
                child: Icon(Icons.person, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FontAwesomeIcons.userDoctor,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _userName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'RedSyncPH Healthcare Provider Portal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Real-time Stats Section
                    _buildRealTimeStatsSection(),
                    SizedBox(height: 24),

                    // Recent Patients Section
                    _buildSectionHeader('Recent Patient Activity', FontAwesomeIcons.users),
                    SizedBox(height: 16),
                    _buildRecentPatients(),
                    SizedBox(height: 24),

                    // Pending Requests Section
                    _buildSectionHeader('Pending Requests', FontAwesomeIcons.inbox),
                    SizedBox(height: 16),
                    _buildPendingRequests(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeStatsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('data_sharing')
          .where('providerUid', isEqualTo: currentUid)
          .where('active', isEqualTo: true)
          .snapshots(),
      builder: (context, patientsSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('data_sharing_requests')
              .where('providerUid', isEqualTo: currentUid)
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, requestsSnapshot) {
            final totalPatients = patientsSnapshot.data?.docs.length ?? 0;
            final pendingRequests = requestsSnapshot.data?.docs.length ?? 0;

            return Row(
              children: [
                Expanded(
                  child: _buildStatContainer(
                    icon: FontAwesomeIcons.users,
                    value: '$totalPatients',
                    label: 'Active Patients',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatContainer(
                    icon: FontAwesomeIcons.envelope,
                    value: '$pendingRequests',
                    label: 'Pending Requests',
                    color: Colors.orange,
                  ),
                ),
              ],
            );
          },
        );
      },
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade700.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blue.shade700),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPatients() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('data_sharing')
          .where('providerUid', isEqualTo: currentUid)
          .where('active', isEqualTo: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final patients = snapshot.data?.docs ?? [];

        if (patients.isEmpty) {
          return Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(FontAwesomeIcons.users, size: 32, color: Colors.grey.shade400),
                  SizedBox(height: 12),
                  Text(
                    'No patients yet',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: patients.take(3).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, color: Colors.blue.shade700),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient ID: ${data['patientUid'].substring(0, 8)}...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Data sharing active',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPendingRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('data_sharing_requests')
          .where('providerUid', isEqualTo: currentUid)
          .where('status', isEqualTo: 'pending')
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
          return Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(FontAwesomeIcons.inbox, size: 32, color: Colors.grey.shade400),
                  SizedBox(height: 12),
                  Text(
                    'No pending requests',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            ...requests.take(2).map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        FontAwesomeIcons.envelope,
                        color: Colors.orange.shade700,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New data sharing request',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Patient ID: ${data['patientUid'].substring(0, 8)}...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.orange.shade400),
                  ],
                ),
              );
            }),
            if (requests.length > 2)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/healthcare_patients'),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View all ${requests.length} requests',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.blue.shade700,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}