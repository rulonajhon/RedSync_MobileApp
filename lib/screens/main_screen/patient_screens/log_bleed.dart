// ...existing imports...
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

part '../../../models/offline/log_bleed.g.dart';

@HiveType(typeId: 0)
class BleedLog extends HiveObject {
  @HiveField(0)
  String date;
  @HiveField(1)
  String time;
  @HiveField(2)
  String bodyRegion;
  @HiveField(3)
  String severity;
  // Add photo field if needed

  BleedLog({
    required this.date,
    required this.time,
    required this.bodyRegion,
    required this.severity,
    // photo
  });
}

class LogBleed extends StatefulWidget {
  const LogBleed({super.key});

  @override
  State<LogBleed> createState() => _LogBleedState();
}

class _LogBleedState extends State<LogBleed> {
  final PageController _pageController = PageController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _specificRegionController = TextEditingController();
  int _currentPage = 0;

  final List<String> _pageTitles = [
    'When did this happen?',
    'Which body region?',
    'How severe was it?',
    'Add a photo',
    'Review & Save'
  ];

  final List<String> _pageSubtitles = [
    'Select the date and time of the bleed',
    'Tap the area where the bleed occurred',
    'Rate the severity of the bleed',
    'Upload a photo (optional)',
    'Check your information before saving'
  ];

  String _bodyRegion = '';
  String _specificRegion = '';
  String _severity = '';
  bool _showSpecificInput = false;

  final Map<String, List<String>> _regionOptions = {
    'Head': ['Forehead', 'Temple', 'Eye area', 'Nose', 'Mouth', 'Jaw', 'Other'],
    'Neck': ['Front', 'Back', 'Side', 'Other'],
    'Chest': ['Upper chest', 'Lower chest', 'Ribs', 'Other'],
    'Arm': ['Shoulder', 'Upper arm', 'Elbow', 'Forearm', 'Wrist', 'Hand', 'Fingers', 'Other'],
    'Abdomen': ['Upper abdomen', 'Lower abdomen', 'Side', 'Other'],
    'Leg': ['Hip', 'Thigh', 'Knee', 'Shin', 'Calf', 'Ankle', 'Foot', 'Toes', 'Other'],
    'Foot': ['Heel', 'Arch', 'Toes', 'Top of foot', 'Ankle', 'Other'],
    'Other': ['Specify location'],
  };

  @override
  void initState() {
    super.initState();
    _initHive();
    _setCurrentDateTime(); // Automatically set current date and time
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _specificRegionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      _timeController.text = DateFormat('hh:mm a').format(dt);
    }
  }

  void _setCurrentDateTime() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(now);
    _timeController.text = DateFormat('hh:mm a').format(now);
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _initHive() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BleedLogAdapter());
    }
    await Hive.openBox<BleedLog>('bleed_logs');
  }

  Future<void> _saveLog() async {
    final box = Hive.box<BleedLog>('bleed_logs');
    final finalBodyRegion = _specificRegion.isNotEmpty 
        ? '$_bodyRegion - $_specificRegion' 
        : _bodyRegion;
    
    final log = BleedLog(
      date: _dateController.text,
      time: _timeController.text,
      bodyRegion: finalBodyRegion,
      severity: _severity,
    );
    await box.add(log);
  }

  Widget _buildDateTimePage() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                size: 80,
                color: Colors.redAccent.withOpacity(0.7),
              ),
              SizedBox(height: 40),
              Text(
                'Date and time have been set to now. Tap to change if needed.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.redAccent, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Date',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _dateController.text.isEmpty ? 'Select Date' : _dateController.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: _dateController.text.isEmpty ? Colors.grey : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.access_time, color: Colors.redAccent, size: 32),
                            SizedBox(height: 8),
                            Text(
                              'Time',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _timeController.text.isEmpty ? 'Select Time' : _timeController.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: _timeController.text.isEmpty ? Colors.grey : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyRegionPage() {
    final regions = [
      {'name': 'Head', 'icon': Icons.face},
      {'name': 'Neck', 'icon': Icons.person},
      {'name': 'Chest', 'icon': Icons.favorite},
      {'name': 'Arm', 'icon': Icons.back_hand},
      {'name': 'Abdomen', 'icon': Icons.circle},
      {'name': 'Leg', 'icon': Icons.directions_walk},
      {'name': 'Foot', 'icon': Icons.directions_run},
      {'name': 'Other', 'icon': Icons.more_horiz},
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.accessibility_new,
                  size: 60,
                  color: Colors.redAccent.withOpacity(0.7),
                ),
                SizedBox(height: 24),
                
                // Body Region Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    final region = regions[index];
                    final isSelected = _bodyRegion == region['name'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _bodyRegion = region['name'] as String;
                          _specificRegion = '';
                          _specificRegionController.clear();
                          _showSpecificInput = false;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.redAccent.withOpacity(0.1) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.redAccent : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              region['icon'] as IconData,
                              size: 28,
                              color: isSelected ? Colors.redAccent : Colors.grey.shade600,
                            ),
                            SizedBox(height: 6),
                            Text(
                              region['name'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isSelected ? Colors.redAccent : Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                SizedBox(height: 24),
                
                // Specific Region Selection
                if (_bodyRegion.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Be more specific (optional)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        if (!_showSpecificInput) ...[
                          DropdownButtonFormField<String>(
                            value: _specificRegion.isEmpty ? null : _specificRegion,
                            decoration: InputDecoration(
                              hintText: 'Select specific area',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _regionOptions[_bodyRegion]?.map((option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList() ?? [],
                            onChanged: (value) {
                              setState(() {
                                _specificRegion = value ?? '';
                                if (value == 'Other' || value == 'Specify location') {
                                  _showSpecificInput = true;
                                  _specificRegionController.clear();
                                }
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showSpecificInput = true;
                                _specificRegion = '';
                              });
                            },
                            icon: Icon(Icons.edit, size: 16),
                            label: Text('Type custom location'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ] else ...[
                          TextField(
                            controller: _specificRegionController,
                            decoration: InputDecoration(
                              hintText: 'Type specific location...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  setState(() {
                                    _specificRegion = _specificRegionController.text;
                                    _showSpecificInput = false;
                                  });
                                },
                              ),
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                _specificRegion = value;
                                _showSpecificInput = false;
                              });
                            },
                          ),
                          SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showSpecificInput = false;
                                _specificRegionController.clear();
                              });
                            },
                            icon: Icon(Icons.arrow_back, size: 16),
                            label: Text('Back to dropdown'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        
                        if (_specificRegion.isNotEmpty && !_showSpecificInput) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Selected: $_specificRegion',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityPage() {
    final severityLevels = [
      {'name': 'Mild', 'icon': Icons.sentiment_satisfied, 'color': Colors.green},
      {'name': 'Moderate', 'icon': Icons.sentiment_neutral, 'color': Colors.orange},
      {'name': 'Severe', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
    ];

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thermostat,
                size: 80,
                color: Colors.redAccent.withOpacity(0.7),
              ),
              SizedBox(height: 40),
              ...severityLevels.map((level) {
                final isSelected = _severity == level['name'];
                
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => setState(() => _severity = level['name'] as String),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? (level['color'] as Color).withOpacity(0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? level['color'] as Color : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            level['icon'] as IconData,
                            size: 32,
                            color: isSelected ? level['color'] as Color : Colors.grey.shade600,
                          ),
                          SizedBox(width: 16),
                          Text(
                            level['name'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? level['color'] as Color : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPage() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera,
                size: 80,
                color: Colors.redAccent.withOpacity(0.7),
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey.shade500),
                    SizedBox(height: 16),
                    Text(
                      'No photo selected',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement camera
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement gallery
                      },
                      icon: Icon(Icons.photo_library),
                      label: Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewPage() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fact_check,
                size: 80,
                color: Colors.redAccent.withOpacity(0.7),
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReviewItem('Date', _dateController.text, Icons.calendar_today),
                    Divider(height: 24),
                    _buildReviewItem('Time', _timeController.text, Icons.access_time),
                    Divider(height: 24),
                    _buildReviewItem('Body Region', _bodyRegion, Icons.accessibility_new),
                    Divider(height: 24),
                    _buildReviewItem('Severity', _severity, Icons.thermostat),
                  ],
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _saveLog();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bleed log saved successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushReplacementNamed(context, '/user_screen');
                  },
                  icon: Icon(Icons.save),
                  label: Text('Save Bleed Log'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent, size: 20),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'Not selected' : value,
            style: TextStyle(
              color: value.isEmpty ? Colors.grey : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _pageTitles[_currentPage],
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _pageSubtitles[_currentPage],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / 5,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildDateTimePage(),
                    _buildBodyRegionPage(),
                    _buildSeverityPage(),
                    _buildPhotoPage(),
                    _buildReviewPage(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _prevPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.grey.shade700,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: 16),
                  if (_currentPage < 4)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Next'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: Turn each into Vertical Multi Step Form