import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore.dart';

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
                return _buildInfoContainer([
                  _buildInfoRow(
                    'Emergency Phone',
                    contact['contactPhone'] ?? 'Not specified',
                  ),
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
}
