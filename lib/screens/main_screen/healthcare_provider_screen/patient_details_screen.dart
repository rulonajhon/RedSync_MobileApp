import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore.dart';
import '../shared/chat_screen.dart';
=======
import '../../../services/firestore.dart';
>>>>>>> 4b0ff77affb444a0ec3f66fb1eb3be6963703be5

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.patientData['name'] ?? 'Patient Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showPatientActionsMenu();
            },
            icon: Icon(FontAwesomeIcons.ellipsisVertical, size: 18),
          ),
        ],
      ),
      body: Column(
        children: [
          // Patient Header
          _buildPatientHeader(),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
<<<<<<< HEAD
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.redAccent,
              labelColor: Colors.redAccent,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'History'),
                Tab(text: 'Logs'),
=======
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.patientData['hemophiliaType'] ??
                              'Hemophilia A',
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
>>>>>>> 4b0ff77affb444a0ec3f66fb1eb3be6963703be5
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

  Widget _buildPatientHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.redAccent, Colors.red.shade700],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    (widget.patientData['name'] ?? 'P')[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                    SizedBox(height: 4),
                    Text(
                      widget.patientData['email'] ?? 'No email',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        participant: {
                          'id': widget.patientUid,
                          'name': widget.patientData['name'],
                          'role': 'patient',
                          'profilePicture':
                              widget.patientData['profilePicture'],
                        },
                        currentUserRole: 'medical',
                      ),
                    ),
                  );
                },
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FontAwesomeIcons.message,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderStat(
                'Type',
                widget.patientData['hemophiliaType'] ?? 'Hemophilia A',
              ),
              SizedBox(width: 20),
              _buildHeaderStat('Age', _calculateAge(widget.patientData['dob'])),
              SizedBox(width: 20),
              _buildHeaderStat(
                'Blood Type',
                widget.patientData['bloodType'] ?? 'Not specified',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
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
          _buildSectionTitle('Personal Information'),
          SizedBox(height: 16),
<<<<<<< HEAD
          _buildInfoGrid([
            _buildInfoItem(
              'Full Name',
              widget.patientData['name'] ?? 'Not specified',
            ),
            _buildInfoItem(
              'Email',
              widget.patientData['email'] ?? 'Not specified',
            ),
            _buildInfoItem(
              'Gender',
              widget.patientData['gender'] ?? 'Not specified',
            ),
            _buildInfoItem(
              'Date of Birth',
              _formatDate(widget.patientData['dob']),
            ),
            _buildInfoItem(
              'Weight',
              _formatWeight(widget.patientData['weight']),
            ),
            _buildInfoItem(
              'Blood Type',
              widget.patientData['bloodType'] ?? 'Not specified',
            ),
          ]),

          SizedBox(height: 32),

          _buildSectionTitle('Medical Information'),
          SizedBox(height: 16),
          _buildInfoGrid([
            _buildInfoItem(
              'Hemophilia Type',
              widget.patientData['hemophiliaType'] ?? 'Hemophilia A',
            ),
            _buildInfoItem(
              'Inhibitor Status',
              widget.patientData['inhibitorStatus'] ?? 'Not specified',
            ),
          ]),

          SizedBox(height: 32),
=======
          _buildInfoContainer([
            _buildInfoRow(
              'Name',
              widget.patientData['name'] ?? 'Not specified',
            ),
            _buildInfoRow(
              'Email',
              widget.patientData['email'] ?? 'Not specified',
            ),
            _buildInfoRow(
              'Gender',
              widget.patientData['gender'] ?? 'Not specified',
            ),
            _buildInfoRow(
              'Date of Birth',
              widget.patientData['dob'] != null
                  ? DateTime.parse(
                      widget.patientData['dob'],
                    ).toString().split(' ')[0]
                  : 'Not specified',
            ),
            _buildInfoRow(
              'Weight',
              widget.patientData['weight'] != null &&
                      widget.patientData['weight'].isNotEmpty
                  ? '${widget.patientData['weight']} kg'
                  : 'Not specified',
            ),
          ]),

          SizedBox(height: 24),

          _buildSectionTitle('Medical Information'),
          SizedBox(height: 16),
          _buildInfoContainer([
            _buildInfoRow(
              'Hemophilia Type',
              widget.patientData['hemophiliaType'] ?? 'Hemophilia A',
            ),
            _buildInfoRow(
              'Severity',
              widget.patientData['severity'] ?? 'Not specified',
            ),
            _buildInfoRow(
              'Factor Level',
              widget.patientData['factorLevel'] ?? 'Not specified',
            ),
          ]),

          SizedBox(height: 24),
>>>>>>> 4b0ff77affb444a0ec3f66fb1eb3be6963703be5

          _buildSectionTitle('Emergency Contact'),
          SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('emergency_contacts')
                .where('patientUid', isEqualTo: widget.patientUid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final contact =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;
<<<<<<< HEAD
                return _buildInfoGrid([
                  _buildInfoItem(
                    'Emergency Phone',
                    contact['contactPhone'] ?? 'Not specified',
                  ),
                  _buildInfoItem(
                    'Contact Name',
                    contact['contactName'] ?? 'Not specified',
                  ),
                  _buildInfoItem(
                    'Relationship',
                    contact['relationship'] ?? 'Not specified',
                  ),
=======
                return _buildInfoContainer([
                  _buildInfoRow(
                    'Emergency Phone',
                    contact['contactPhone'] ?? 'Not specified',
                  ),
>>>>>>> 4b0ff77affb444a0ec3f66fb1eb3be6963703be5
                ]);
              }
              return _buildEmptyState(
                icon: FontAwesomeIcons.phoneSlash,
                title: 'No emergency contact',
                subtitle:
                    'Patient hasn\'t provided emergency contact information',
              );
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
          _buildSectionTitle('Recent Treatments'),
          SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('infusions')
                .where('patientUid', isEqualTo: widget.patientUid)
                .orderBy('date', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
<<<<<<< HEAD
                    return _buildTreatmentItem(data);
                  }).toList(),
                );
              }
              return _buildEmptyState(
                icon: FontAwesomeIcons.syringe,
                title: 'No treatment history',
                subtitle: 'Patient hasn\'t logged any treatments yet',
=======
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
                          Icon(
                            FontAwesomeIcons.syringe,
                            color: Colors.purple,
                            size: 20,
                          ),
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
                                ? (data['date'] as Timestamp)
                                      .toDate()
                                      .toString()
                                      .split(' ')[0]
                                : 'Unknown date',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
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
                      Icon(
                        FontAwesomeIcons.syringe,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No treatment history available',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
>>>>>>> 4b0ff77affb444a0ec3f66fb1eb3be6963703be5
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
<<<<<<< HEAD
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Bleeding Episodes'),
            SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _firestoreService.getBleedLogs(
                widget.patientUid,
                limit: 15,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final logs = snapshot.data!;
                  return Column(
                    children: logs
                        .map((log) => _buildBleedLogItem(log))
                        .toList(),
                  );
                }
                return _buildEmptyState(
                  icon: FontAwesomeIcons.droplet,
                  title: 'No bleeding episodes',
                  subtitle: 'Patient hasn\'t logged any bleeding episodes yet',
                );
              },
            ),
          ],
        ),
=======
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Recent Bleeding Episodes'),
          SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _firestoreService.getBleedLogs(
              widget.patientUid,
              limit: 10,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final logs = snapshot.data!;

                if (logs.isNotEmpty) {
                  return Column(
                    children: logs.map((log) {
                      return GestureDetector(
                        onTap: () => _showBleedLogDetails(log),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(
                                    log['severity'] ?? 'Mild',
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  FontAwesomeIcons.droplet,
                                  color: _getSeverityColor(
                                    log['severity'] ?? 'Mild',
                                  ),
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log['bodyRegion'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      log['severity'] ?? 'Mild',
                                      style: TextStyle(
                                        color: _getSeverityColor(
                                          log['severity'] ?? 'Mild',
                                        ),
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
                                    log['date'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    log['time'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ],
                          ),
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
                      Icon(
                        FontAwesomeIcons.droplet,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
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
>>>>>>> 4b0ff77affb444a0ec3f66fb1eb3be6963703be5
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoGrid(List<Widget> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(child: items[i]),
                if (i + 1 < items.length) ...[
                  SizedBox(width: 16),
                  Expanded(child: items[i + 1]),
                ] else
                  Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentItem(Map<String, dynamic> data) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              FontAwesomeIcons.syringe,
              color: Colors.purple,
              size: 16,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['medication'] ?? 'Unknown medication',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${data['doseIU'] ?? 0} IU',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(data['date']),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBleedLogItem(Map<String, dynamic> log) {
    final severity = log['severity'] ?? 'Mild';
    final color = _getSeverityColor(severity);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => _showBleedLogDetails(log),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(FontAwesomeIcons.droplet, color: color, size: 16),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log['bodyRegion'] ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          severity,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${log['date'] ?? 'Unknown'} • ${log['time'] ?? 'Unknown'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        FontAwesomeIcons.chevronRight,
                        color: Colors.grey.shade400,
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
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
      padding: EdgeInsets.all(40),
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
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPatientActionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Patient Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildActionItem(
              icon: FontAwesomeIcons.message,
              title: 'Send Message',
              subtitle: 'Start a conversation',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      participant: {
                        'id': widget.patientUid,
                        'name': widget.patientData['name'],
                        'role': 'patient',
                        'profilePicture': widget.patientData['profilePicture'],
                      },
                      currentUserRole: 'medical',
                    ),
                  ),
                );
              },
            ),
            _buildActionItem(
              icon: FontAwesomeIcons.userXmark,
              title: 'Remove Access',
              subtitle: 'Revoke data sharing',
              onTap: () {
                Navigator.pop(context);
                _confirmRemoveAccess();
              },
              isDestructive: true,
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.grey.shade700,
          size: 16,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
      onTap: onTap,
    );
  }

  void _confirmRemoveAccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Data Access'),
        content: Text(
          'Are you sure you want to revoke data sharing access for this patient? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeDataAccess();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeDataAccess() async {
    try {
      // Find and delete the data sharing relationship
      final dataSharingQuery = await FirebaseFirestore.instance
          .collection('data_sharing')
          .where('patientUid', isEqualTo: widget.patientUid)
          .where(
            'providerUid',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid,
          )
          .get();

      for (var doc in dataSharingQuery.docs) {
        await doc.reference.delete();
      }

      // Send notification to patient
      await _firestoreService.createNotification(
        widget.patientUid,
        'Your healthcare provider has revoked data sharing access.',
      );

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data access removed successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(); // Go back to patients list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing access: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBleedLogDetails(Map<String, dynamic> log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(log['severity'] ?? 'Mild'),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            FontAwesomeIcons.droplet,
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
                                'Bleeding Episode',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${log['date'] ?? 'Unknown'} at ${log['time'] ?? 'Unknown'}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection('Episode Information', [
                            _buildDetailRow(
                              'Body Region',
                              log['bodyRegion'] ?? 'Not specified',
                            ),
                            _buildDetailRow(
                              'Specific Region',
                              log['specificRegion']?.isNotEmpty == true
                                  ? log['specificRegion']
                                  : 'Not specified',
                            ),
                            _buildDetailRow(
                              'Severity',
                              log['severity'] ?? 'Not specified',
                            ),
                            _buildDetailRow(
                              'Date',
                              log['date'] ?? 'Not specified',
                            ),
                            _buildDetailRow(
                              'Time',
                              log['time'] ?? 'Not specified',
                            ),
                          ]),

                          SizedBox(height: 24),

                          if (log['notes']?.isNotEmpty == true) ...[
                            _buildDetailSection('Additional Notes', [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  log['notes'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ]),
                            SizedBox(height: 24),
                          ],

                          _buildDetailSection('Patient Information', [
                            _buildDetailRow(
                              'Patient Name',
                              widget.patientData['name'] ?? 'Unknown',
                            ),
                            _buildDetailRow(
                              'Hemophilia Type',
                              widget.patientData['hemophiliaType'] ??
                                  'Not specified',
                            ),
                          ]),

                          SizedBox(height: 24),

                          if (log['createdAt'] != null) ...[
                            _buildDetailSection('Log Information', [
                              _buildDetailRow(
                                'Logged At',
                                _formatTimestamp(log['createdAt']),
                              ),
                              _buildDetailRow('Log ID', log['id'] ?? 'Unknown'),
                            ]),
                            SizedBox(height: 24),
                          ],

                          // Severity indicator
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(
                                log['severity'] ?? 'Mild',
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getSeverityColor(
                                  log['severity'] ?? 'Mild',
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getSeverityIcon(log['severity'] ?? 'Mild'),
                                  color: _getSeverityColor(
                                    log['severity'] ?? 'Mild',
                                  ),
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${log['severity'] ?? 'Mild'} Severity',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: _getSeverityColor(
                                            log['severity'] ?? 'Mild',
                                          ),
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _getSeverityDescription(
                                          log['severity'] ?? 'Mild',
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
                fontSize: 14,
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
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp != null) {
        DateTime date;
        if (timestamp is Timestamp) {
          date = timestamp.toDate();
        } else if (timestamp is String) {
          date = DateTime.parse(timestamp);
        } else {
          return 'Unknown';
        }
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      // Handle error silently
    }
    return 'Unknown';
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Icons.sentiment_satisfied;
      case 'moderate':
        return Icons.sentiment_neutral;
      case 'severe':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  String _getSeverityDescription(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return 'Minor bleeding episode that may not require immediate treatment';
      case 'moderate':
        return 'Moderate bleeding that may require factor replacement therapy';
      case 'severe':
        return 'Serious bleeding episode requiring immediate medical attention';
      default:
        return 'Severity level not specified';
    }
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

<<<<<<< HEAD
  String _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return 'Unknown';
    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return '$age years';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Not specified';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Not specified';
    }
  }

  String _formatWeight(String? weight) {
    if (weight == null || weight.isEmpty) return 'Not specified';
    return '$weight kg';
  }
=======
  void _showBleedLogDetails(Map<String, dynamic> log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(log['severity'] ?? 'Mild'),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FontAwesomeIcons.droplet,
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
                              'Bleeding Episode',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${log['date'] ?? 'Unknown'} at ${log['time'] ?? 'Unknown'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Episode Information', [
                          _buildDetailRow(
                            'Body Region',
                            log['bodyRegion'] ?? 'Not specified',
                          ),
                          _buildDetailRow(
                            'Specific Region',
                            log['specificRegion']?.isNotEmpty == true
                                ? log['specificRegion']
                                : 'Not specified',
                          ),
                          _buildDetailRow(
                            'Severity',
                            log['severity'] ?? 'Not specified',
                          ),
                          _buildDetailRow(
                            'Date',
                            log['date'] ?? 'Not specified',
                          ),
                          _buildDetailRow(
                            'Time',
                            log['time'] ?? 'Not specified',
                          ),
                        ]),

                        SizedBox(height: 24),

                        if (log['notes']?.isNotEmpty == true) ...[
                          _buildDetailSection('Additional Notes', [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                log['notes'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ]),
                          SizedBox(height: 24),
                        ],

                        _buildDetailSection('Patient Information', [
                          _buildDetailRow(
                            'Patient Name',
                            widget.patientData['name'] ?? 'Unknown',
                          ),
                          _buildDetailRow(
                            'Hemophilia Type',
                            widget.patientData['hemophiliaType'] ??
                                'Not specified',
                          ),
                          _buildDetailRow(
                            'Severity Level',
                            widget.patientData['severity'] ?? 'Not specified',
                          ),
                        ]),

                        SizedBox(height: 24),

                        if (log['createdAt'] != null) ...[
                          _buildDetailSection('Log Information', [
                            _buildDetailRow(
                              'Logged At',
                              _formatTimestamp(log['createdAt']),
                            ),
                            _buildDetailRow('Log ID', log['id'] ?? 'Unknown'),
                          ]),
                          SizedBox(height: 24),
                        ],

                        // Severity indicator
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(
                              log['severity'] ?? 'Mild',
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getSeverityColor(
                                log['severity'] ?? 'Mild',
                              ).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getSeverityIcon(log['severity'] ?? 'Mild'),
                                color: _getSeverityColor(
                                  log['severity'] ?? 'Mild',
                                ),
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${log['severity'] ?? 'Mild'} Severity',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _getSeverityColor(
                                          log['severity'] ?? 'Mild',
                                        ),
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _getSeverityDescription(
                                        log['severity'] ?? 'Mild',
                                      ),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
                fontSize: 14,
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
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp != null) {
        DateTime date;
        if (timestamp is int) {
          date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else if (timestamp.toDate != null) {
          date = timestamp.toDate();
        } else {
          return 'Unknown';
        }
        return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Handle error silently
    }
    return 'Unknown';
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return Icons.sentiment_satisfied;
      case 'moderate':
        return Icons.sentiment_neutral;
      case 'severe':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  String _getSeverityDescription(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return 'Minor bleeding episode that may not require immediate treatment';
      case 'moderate':
        return 'Moderate bleeding that may require factor replacement therapy';
      case 'severe':
        return 'Serious bleeding episode requiring immediate medical attention';
      default:
        return 'Severity level not specified';
    }
  }
>>>>>>> 4b0ff77affb444a0ec3f66fb1eb3be6963703be5
}
