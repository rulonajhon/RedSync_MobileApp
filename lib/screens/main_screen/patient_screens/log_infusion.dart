import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

part '../../../models/offline/log_infusion.g.dart';

@HiveType(typeId: 1)
class InfusionLog extends HiveObject {
  @HiveField(0)
  String medication;
  @HiveField(1)
  int doseIU;
  @HiveField(2)
  String date;
  @HiveField(3)
  String time;
  @HiveField(4)
  String notes;

  InfusionLog({
    required this.medication,
    required this.doseIU,
    required this.date,
    required this.time,
    required this.notes,
  });
}

class LogInfusionScreen extends StatefulWidget {
  const LogInfusionScreen({super.key});

  @override
  State<LogInfusionScreen> createState() => _LogInfusionScreenState();
}

class _LogInfusionScreenState extends State<LogInfusionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSaving = false;
  String _selectedMedicationType = '';

  final List<String> _medicationTypes = [
    'Factor VIII',
    'Factor IX',
    'Factor XI',
    'Desmopressin (DDAVP)',
    'Antifibrinolytic agents',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _initHive();
  }

  Future<void> _initHive() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(InfusionLogAdapter());
    }
    await Hive.openBox<InfusionLog>('infusion_logs');
  }

  Future<void> _saveInfusion() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }
    setState(() => _isSaving = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final timeStr = _selectedTime!.format(context);

    final log = InfusionLog(
      medication: _medicationController.text.trim(),
      doseIU: int.tryParse(_doseController.text.trim()) ?? 0,
      date: dateStr,
      time: timeStr,
      notes: _notesController.text.trim(),
    );

    final box = Hive.box<InfusionLog>('infusion_logs');
    await box.add(log);

    setState(() => _isSaving = false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Log Infusion',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
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
                          Icons.medical_services,
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
                              'Record your infusion',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Keep track of your medication intake',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Medication Type Section
                      _buildSectionContainer(
                        title: 'Medication Information',
                        icon: Icons.medication,
                        children: [
                          _buildMedicationSelector(),
                          SizedBox(height: 16),
                          _buildCustomInput(
                            controller: _medicationController,
                            label: 'Specific Medication Name',
                            icon: Icons.medical_services_outlined,
                            validator: (v) => v == null || v.isEmpty ? 'Enter medication name' : null,
                          ),
                          SizedBox(height: 16),
                          _buildCustomInput(
                            controller: _doseController,
                            label: 'Dose (IU)',
                            icon: Icons.colorize,
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Enter dose amount' : null,
                          ),
                        ],
                      ),
        
                      SizedBox(height: 20),
        
                      // Date & Time Section
                      _buildSectionContainer(
                        title: 'When was this taken?',
                        icon: Icons.schedule,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateTimeSelector(
                                  label: 'Date',
                                  value: _selectedDate != null 
                                      ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                                      : 'Select date',
                                  icon: Icons.calendar_today,
                                  onTap: _pickDate,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: _buildDateTimeSelector(
                                  label: 'Time',
                                  value: _selectedTime != null 
                                      ? _selectedTime!.format(context)
                                      : 'Select time',
                                  icon: Icons.access_time,
                                  onTap: _pickTime,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
        
                      SizedBox(height: 20),
        
                      // Notes Section
                      _buildSectionContainer(
                        title: 'Additional Notes (Optional)',
                        icon: Icons.note_outlined,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: _notesController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Any additional notes about this infusion...',
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
        
                      SizedBox(height: 32),
        
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveInfusion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: _isSaving 
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.save, size: 20),
                          label: Text(
                            _isSaving ? 'Saving...' : 'Save Infusion',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.deepPurple, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMedicationSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedMedicationType.isEmpty ? null : _selectedMedicationType,
        decoration: InputDecoration(
          hintText: 'Select medication type',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.bloodtype, color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _medicationTypes.map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedMedicationType = value ?? '');
          if (value == 'Other') {
            _medicationController.clear();
          } else if (value != null) {
            _medicationController.text = value;
          }
        },
      ),
    );
  }

  Widget _buildCustomInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 20),
            SizedBox(width: 12),
            Expanded(
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
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
