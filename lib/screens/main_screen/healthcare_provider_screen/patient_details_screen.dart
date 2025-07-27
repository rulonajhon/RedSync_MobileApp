import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../../services/firestore.dart';
import '../patient_screens/log_bleed.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientUid;
  final Map<String, dynamic> patientData;

  const PatientDetailsScreen({
    super.key,
    required this.patientUid,
    required this.patientData,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.patientData['name'] ?? 'Patient Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Medical History'),
            Tab(text: 'Logs'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Patient Header
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    (widget.patientData['name'] ?? 'P')[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patientData['name'] ?? 'Unknown Patient',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.patientData['email'] ?? 'No email',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.patientData['hemophiliaType'] ?? 'Hemophilia A',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildMedicalHistoryTab(),
                _buildLogsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Patient Information'),
          SizedBox(height: 16),
          _buildInfoContainer([
            _buildInfoRow('Name', widget.patientData['name'] ?? 'Not specified'),
            _buildInfoRow('Email', widget.patientData['email'] ?? 'Not specified'),
            _buildInfoRow('Gender', widget.patientData['gender'] ?? 'Not specified'),
            _buildInfoRow('Date of Birth', 
              widget.patientData['dob'] != null 
                ? DateTime.parse(widget.patientData['dob']).toString().split(' ')[0]
                : 'Not specified'),
            _buildInfoRow('Weight', 
              widget.patientData['weight'] != null && widget.patientData['weight'].isNotEmpty
                ? '${widget.patientData['weight']} kg'
                : 'Not specified'),
          ]),
          
          SizedBox(height: 24),
          
          _buildSectionTitle('Medical Information'),
          SizedBox(height: 16),
          _buildInfoContainer([
            _buildInfoRow('Hemophilia Type', widget.patientData['hemophiliaType'] ?? 'Hemophilia A'),
            _buildInfoRow('Severity', widget.patientData['severity'] ?? 'Not specified'),
            _buildInfoRow('Factor Level', widget.patientData['factorLevel'] ?? 'Not specified'),
          ]),
          
          SizedBox(height: 24),
          
          _buildSectionTitle('Emergency Contact'),
          SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('emergency_contacts')
                .where('patientUid', isEqualTo: widget.patientUid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final contact = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                return _buildInfoContainer([
                  _buildInfoRow('Emergency Phone', contact['contactPhone'] ?? 'Not specified'),
                ]);
              }
              return _buildInfoContainer([
                _buildInfoRow('Emergency Phone', 'Not specified'),
              ]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Treatment History'),
          SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('infusions')
                .where('patientUid', isEqualTo: widget.patientUid)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Column(
                  children: snapshot.data!.docs.map((doc) {
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
                          Icon(FontAwesomeIcons.syringe, color: Colors.purple, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['medication'] ?? 'Unknown medication',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${data['doseIU'] ?? 0} IU',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            data['date'] != null 
                              ? (data['date'] as Timestamp).toDate().toString().split(' ')[0]
                              : 'Unknown date',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
              return Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(FontAwesomeIcons.syringe, size: 48, color: Colors.grey.shade400),
                      SizedBox(height: 16),
                      Text(
                        'No treatment history available',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Recent Bleeding Episodes'),
          SizedBox(height: 16),
          FutureBuilder<Box<BleedLog>>(
            future: Hive.openBox<BleedLog>('bleed_logs_${widget.patientUid}'),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final box = snapshot.data!;
                final logs = box.values.take(10).toList();
                
                if (logs.isNotEmpty) {
                  return Column(
                    children: logs.map((log) {
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
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(log.severity).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                FontAwesomeIcons.droplet,
                                color: _getSeverityColor(log.severity),
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.bodyRegion,
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    log.severity,
                                    style: TextStyle(
                                      color: _getSeverityColor(log.severity),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  log.date,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                                Text(
                                  log.time,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              }
              
              return Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(FontAwesomeIcons.droplet, size: 48, color: Colors.grey.shade400),
                      SizedBox(height: 16),
                      Text(
                        'No bleeding episodes logged yet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
