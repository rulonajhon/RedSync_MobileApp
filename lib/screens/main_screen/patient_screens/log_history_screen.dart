import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'log_bleed.dart'; // adjust path if needed
import 'log_infusion.dart'; // adjust path if needed

class LogHistoryScreen extends StatefulWidget {
  const LogHistoryScreen({super.key});

  @override
  State<LogHistoryScreen> createState() => _LogHistoryScreenState();
}

class _LogHistoryScreenState extends State<LogHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Ensure Hive box is open
    Hive.openBox<BleedLog>('bleed_logs');
    Hive.openBox<InfusionLog>('infusion_logs');
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
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<BleedLog>('bleed_logs').listenable(),
                    builder: (context, Box<BleedLog> box, _) {
                      if (box.isEmpty) {
                        return Center(
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
                        );
                      }
                      return ListView.separated(
                        itemCount: box.length,
                        separatorBuilder: (context, index) => Container(
                          height: 1,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          color: Colors.grey.shade200,
                        ),
                        itemBuilder: (context, index) {
                          final log = box.getAt(index);
                          if (log == null) return SizedBox.shrink();
                          
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                                    color: _getSeverityColor(log.severity).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.bloodtype,
                                    color: _getSeverityColor(log.severity),
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            log.bodyRegion,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getSeverityColor(log.severity).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              log.severity,
                                              style: TextStyle(
                                                color: _getSeverityColor(log.severity),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                          SizedBox(width: 4),
                                          Text(
                                            log.date,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                          SizedBox(width: 4),
                                          Text(
                                            log.time,
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
                      );
                    },
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
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<InfusionLog>('infusion_logs').listenable(),
              builder: (context, Box<InfusionLog> box, _) {
                if (box.isEmpty) {
                  return Center(
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
                          'No infusions recorded yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your infusion history will appear here',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: box.length,
                  separatorBuilder: (context, index) => Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final log = box.getAt(index);
                    if (log == null) return SizedBox.shrink();
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                              color: Colors.green.withOpacity(0.1),
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
                                  log.medication,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Dose: ${log.doseIU} IU',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                    SizedBox(width: 4),
                                    Text(
                                      log.date,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                    SizedBox(width: 4),
                                    Text(
                                      log.time,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                if (log.notes.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    'Notes: ${log.notes}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
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
                );
              },
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
                color: color.withOpacity(0.1),
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
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
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
