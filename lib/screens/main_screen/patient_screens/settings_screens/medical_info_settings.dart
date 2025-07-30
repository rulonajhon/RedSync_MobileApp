import 'package:flutter/material.dart';
import 'package:hemophilia_manager/auth/auth.dart';
import 'package:hemophilia_manager/services/firestore.dart';

class MedicalInfoSettings extends StatefulWidget {
  const MedicalInfoSettings({super.key});

  @override
  State<MedicalInfoSettings> createState() => _MedicalInfoSettingsState();
}

class _MedicalInfoSettingsState extends State<MedicalInfoSettings> {
  String gender = 'Male';
  DateTime? dob;
  String specialization = 'Hematology';
  String licenseNumber = '';
  String hospitalAffiliation = '';
  String name = '';
  String email = '';
  String photoUrl = '';
  String yearsOfExperience = '';
  bool _isLoading = false;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> specializationOptions = [
    'Hematology',
    'Pediatric Hematology',
    'Internal Medicine',
    'Family Medicine',
    'Emergency Medicine',
    'Other'
  ];

  late TextEditingController _licenseController;
  late TextEditingController _hospitalController;
  late TextEditingController _experienceController;

  @override
  void initState() {
    super.initState();
    _licenseController = TextEditingController();
    _hospitalController = TextEditingController();
    _experienceController = TextEditingController();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _hospitalController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    final user = AuthService().currentUser;
    if (user != null) {
      email = user.email ?? '';
      photoUrl = user.photoURL ?? '';
      final userData = await FirestoreService().getUser(user.uid);
      if (userData != null) {
        setState(() {
          name = userData['name'] ?? '';
          gender = userData['gender'] ?? gender;
          specialization = userData['specialization'] ?? specialization;
          licenseNumber = userData['licenseNumber'] ?? licenseNumber;
          hospitalAffiliation = userData['hospitalAffiliation'] ?? hospitalAffiliation;
          yearsOfExperience = userData['yearsOfExperience'] ?? yearsOfExperience;
          dob = userData['dob'] != null
              ? DateTime.tryParse(userData['dob'])
              : dob;
          
          _licenseController.text = licenseNumber;
          _hospitalController.text = hospitalAffiliation;
          _experienceController.text = yearsOfExperience;
        });
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = AuthService().currentUser;
    if (user != null) {
      await FirestoreService().updateUser(
        user.uid,
        name,
        email,
        null,
        extra: {
          'gender': gender,
          'specialization': specialization,
          'licenseNumber': licenseNumber,
          'hospitalAffiliation': hospitalAffiliation,
          'yearsOfExperience': yearsOfExperience,
          'dob': dob?.toIso8601String(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Medical Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey.shade600,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          name.isEmpty ? 'Loading...' : name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Medical Professional',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Personal Information Section
                  _buildSectionHeader('Personal Information', Icons.person_outline),
                  SizedBox(height: 16),
                  
                  _buildInfoTile(
                    icon: Icons.wc,
                    title: 'Gender',
                    value: gender,
                    onTap: () => _showGenderDialog(),
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildInfoTile(
                    icon: Icons.cake,
                    title: 'Date of Birth',
                    value: dob == null
                        ? 'Not set'
                        : '${dob!.day}/${dob!.month}/${dob!.year}',
                    onTap: () => _selectDateOfBirth(),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Professional Information Section
                  _buildSectionHeader('Professional Information', Icons.medical_services),
                  SizedBox(height: 16),
                  
                  _buildInfoTile(
                    icon: Icons.school,
                    title: 'Specialization',
                    value: specialization,
                    onTap: () => _showSpecializationDialog(),
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildTextFieldTile(
                    controller: _licenseController,
                    icon: Icons.badge,
                    title: 'License Number',
                    hintText: 'Enter license number',
                    onChanged: (val) => setState(() => licenseNumber = val),
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildTextFieldTile(
                    controller: _hospitalController,
                    icon: Icons.local_hospital,
                    title: 'Hospital/Clinic Affiliation',
                    hintText: 'Enter hospital or clinic name',
                    onChanged: (val) => setState(() => hospitalAffiliation = val),
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildTextFieldTile(
                    controller: _experienceController,
                    icon: Icons.work,
                    title: 'Years of Experience',
                    hintText: 'Enter years of experience',
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => yearsOfExperience = val),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveProfile,
                      icon: Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.redAccent,
            size: 20,
          ),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
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
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade600,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
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
      ),
    );
  }

  Widget _buildTextFieldTile({
    required TextEditingController controller,
    required IconData icon,
    required String title,
    required String hintText,
    required Function(String) onChanged,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
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
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGenderDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Gender',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genderOptions.map((g) => 
            ListTile(
              title: Text(g),
              onTap: () => Navigator.pop(context, g),
              trailing: gender == g ? Icon(Icons.check, color: Colors.redAccent) : null,
              contentPadding: EdgeInsets.zero,
            ),
          ).toList(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (selected != null) setState(() => gender = selected);
  }

  Future<void> _showSpecializationDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Specialization',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: specializationOptions.map((s) => 
            ListTile(
              title: Text(s),
              onTap: () => Navigator.pop(context, s),
              trailing: specialization == s ? Icon(Icons.check, color: Colors.redAccent) : null,
              contentPadding: EdgeInsets.zero,
            ),
          ).toList(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (selected != null) setState(() => specialization = selected);
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime(1980, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.redAccent,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => dob = picked);
  }
}
