import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hemophilia_manager/screens/main_screen/healthcare_provider_screen/patient_details_screen.dart';
import '../../../services/firestore.dart';

class HealthcarePatientsList extends StatefulWidget {
  const HealthcarePatientsList({super.key});

  @override
  State<HealthcarePatientsList> createState() => _HealthcarePatientsListState();
}

class _HealthcarePatientsListState extends State<HealthcarePatientsList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRequest(String requestId, String patientUid, bool accept) async {
    try {
      if (accept) {
        // Accept the request
        await FirebaseFirestore.instance.collection('data_sharing_requests').doc(requestId).update({
          'status': 'accepted',
          'acceptedAt': FieldValue.serverTimestamp(),
        });

        // Create a data sharing relationship
        await FirebaseFirestore.instance.collection('data_sharing').add({
          'patientUid': patientUid,
          'providerUid': currentUid,
          'createdAt': FieldValue.serverTimestamp(),
          'active': true,
        });

        // Send notification to patient
        await _firestoreService.createNotification(
          patientUid,
          'Your data sharing request has been accepted by the healthcare provider.',
        );

        _showSnackBar('Request accepted successfully', Colors.green);
      } else {
        // Reject the request
        await FirebaseFirestore.instance.collection('data_sharing_requests').doc(requestId).update({
          'status': 'rejected',
          'rejectedAt': FieldValue.serverTimestamp(),
        });

        // Send notification to patient
        await _firestoreService.createNotification(
          patientUid,
          'Your data sharing request has been declined by the healthcare provider.',
        );

        _showSnackBar('Request rejected', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Error processing request: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.redAccent,
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.black54,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: 'Patients List'),
            Tab(text: 'Incoming Request'),
          ],
        ),
        title: Image.asset('assets/images/app_logo.png', width: 60),
        centerTitle: true,
        foregroundColor: Colors.redAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
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
        child: TabBarView(
          controller: _tabController,
          children: [
            // Patients List Tab
            _buildPatientsListTab(),
            // Incoming Request Tab
            _buildIncomingRequestsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsListTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Text(
            'Patients List',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('data_sharing')
                  .where('providerUid', isEqualTo: currentUid)
                  .where('active', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading patients'));
                }

                final dataSharingDocs = snapshot.data?.docs ?? [];

                if (dataSharingDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No patients yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Patients who share their data with you will appear here',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: dataSharingDocs.length,
                  itemBuilder: (context, index) {
                    final sharingData = dataSharingDocs[index].data() as Map<String, dynamic>;
                    final patientUid = sharingData['patientUid'];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _firestoreService.getUser(patientUid),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text('Loading...'),
                            subtitle: Text('Loading patient data...'),
                          );
                        }

                        final userData = userSnapshot.data!;
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Text(
                                (userData['name'] ?? 'U')[0].toUpperCase(),
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              userData['name'] ?? 'Unknown Patient',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              userData['email'] ?? 'No email',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientDetailsScreen(
                                    patientUid: patientUid,
                                    patientData: userData,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Text(
            'Incoming Requests',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('data_sharing_requests')
                  .where('providerUid', isEqualTo: currentUid)
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading requests'));
                }

                final requests = snapshot.data?.docs ?? [];

                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No pending requests',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Data sharing requests from patients will appear here',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final requestData = request.data() as Map<String, dynamic>;
                    final patientUid = requestData['patientUid'];
                    final requestId = request.id;

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _firestoreService.getUser(patientUid),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text('Loading request...'),
                          );
                        }

                        final userData = userSnapshot.data!;
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    child: Text(
                                      (userData['name'] ?? 'U')[0].toUpperCase(),
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData['name'] ?? 'Unknown Patient',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          userData['email'] ?? 'No email',
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
                              SizedBox(height: 12),
                              Text(
                                'Wants to share their health data with you',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _handleRequest(requestId, patientUid, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text('Accept'),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _handleRequest(requestId, patientUid, false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey.shade300,
                                        foregroundColor: Colors.grey.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text('Decline'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}