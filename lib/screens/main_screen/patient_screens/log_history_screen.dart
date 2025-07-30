import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore.dart';

class LogHistoryScreen extends StatefulWidget {
  const LogHistoryScreen({super.key});

  @override
  State<LogHistoryScreen> createState() => _LogHistoryScreenState();
}

class _LogHistoryScreenState extends State<LogHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _bleedLogs = [];
  List<Map<String, dynamic>> _infusionLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void didUpdateWidget(LogHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when widget updates
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Loading data for user: ${user.uid}'); // Debug log

        // Load bleed logs from Firestore
        final bleeds = await _firestoreService.getBleedLogs(
          user.uid,
          limit: 50,
        );

        print('Loaded ${bleeds.length} bleed logs'); // Debug log

        // Load dosage calculations as infusion logs
        final dosages = await _firestoreService.getDosageCalculationHistory(
          user.uid,
          limit: 50,
        );

        print('Loaded ${dosages.length} dosage calculations'); // Debug log

        setState(() {
          _bleedLogs = bleeds;
          _infusionLogs = dosages;
          _isLoading = false;
        });
      } else {
        print('No user logged in'); // Debug log
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading data: $e'); // Debug log for troubleshooting
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log History',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'Bleeding Episodes'),
            Tab(text: 'Infusion Taken'),
          ],
        ),
      ),
      // TODO: Add a calendar icon and if opened, show a calendar view of logs
      body: TabBarView(
        controller: _tabController,
        children: [
          // Bleeding Episodes tab: show Hive logs
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bloodtype, color: Colors.redAccent, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Bleeding Episodes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Track and monitor your bleeding episodes',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.redAccent,
                          ),
                        )
                      : _bleedLogs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 24),
                              Text(
                                'No bleeding episodes yet',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Your bleeding episodes will appear here',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.separated(
                            itemCount: _bleedLogs.length,
                            separatorBuilder: (context, index) => Container(
                              height: 1,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              color: Colors.grey.shade200,
                            ),
                            itemBuilder: (context, index) {
                              final log = _bleedLogs[index];

                              return Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _getSeverityColor(
                                          log['severity'] ?? 'Mild',
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.bloodtype,
                                        color: _getSeverityColor(
                                          log['severity'] ?? 'Mild',
                                        ),
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                log['bodyRegion'] ?? 'Unknown',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getSeverityColor(
                                                    log['severity'] ?? 'Mild',
                                                  ).withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  log['severity'] ?? 'Mild',
                                                  style: TextStyle(
                                                    color: _getSeverityColor(
                                                      log['severity'] ?? 'Mild',
                                                    ),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (log['specificRegion'] != null &&
                                              log['specificRegion']
                                                  .toString()
                                                  .isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(top: 4),
                                              child: Text(
                                                log['specificRegion'],
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                log['date'] ??
                                                    _formatDate(
                                                      log['createdAt'],
                                                    ),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                log['time'] ??
                                                    _formatTime(
                                                      log['createdAt'],
                                                    ),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (log['notes'] != null &&
                                              log['notes']
                                                  .toString()
                                                  .isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(top: 8),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.note,
                                                    size: 16,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      log['notes'],
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                        fontSize: 14,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey.shade400,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          // Infusion Taken tab
          _buildInfusionTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        heroTag: "log_history_fab", // Unique tag to avoid conflicts
        foregroundColor: Colors.white,
        tooltip: 'Add New Log',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(24),
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
                    SizedBox(height: 20),
                    Text(
                      'Add New Log',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildActionTile(
                      icon: Icons.bloodtype,
                      title: 'Log New Bleeding Episode',
                      subtitle: 'Record a new bleeding incident',
                      color: Colors.redAccent,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/log_bleed');
                      },
                    ),
                    SizedBox(height: 16),
                    _buildActionTile(
                      icon: Icons.medical_services,
                      title: 'Log New Infusion Taken',
                      subtitle: 'Record treatment administration',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/log_infusion');
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfusionTab() {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                'Infusion Taken',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Track your treatment history',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.green))
                : _infusionLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 24),
                        Text(
                          'No dosage calculations yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your dosage calculation history will appear here',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.separated(
                      itemCount: _infusionLogs.length,
                      separatorBuilder: (context, index) => Container(
                        height: 1,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final log = _infusionLogs[index];
                        return Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.medical_services,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${log['factorType'] ?? 'Factor'} Dosage',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Dose: ${log['dosage'] ?? '0'} IU',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Weight: ${log['weight'] ?? '0'} kg',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          _formatTimestamp(log['timestamp']),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey.shade400,
                                size: 24,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
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

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      // Handle error silently
    }
    return 'Unknown';
  }

  String _formatDate(dynamic timestamp) {
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
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      // Handle error silently
    }
    return 'Unknown';
  }

  String _formatTime(dynamic timestamp) {
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
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Handle error silently
    }
    return 'Unknown';
  }
}

class SampleScreen extends StatelessWidget {
  final String screenTitle;
  const SampleScreen({super.key, required this.screenTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            screenTitle,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          // Placeholder ListTile for backend reference
          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.grey),
            title: Text(
              screenTitle == 'Bleeding Episodes'
                  ? 'Sample Bleeding Episode'
                  : 'Sample Infusion Taken',
              style: TextStyle(color: Colors.black54),
            ),
            subtitle: Text(
              screenTitle == 'Bleeding Episodes'
                  ? 'Details about a bleeding episode go here.'
                  : 'Details about an infusion taken go here.',
              style: TextStyle(color: Colors.black38),
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// TODO: Logic for viewing and managing logs in bleeding episodes and infusion taken
