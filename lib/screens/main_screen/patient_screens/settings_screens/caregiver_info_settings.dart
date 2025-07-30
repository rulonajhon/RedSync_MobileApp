import 'package:flutter/material.dart';
import 'package:hemophilia_manager/auth/auth.dart';
import 'package:hemophilia_manager/services/firestore.dart';

class CaregiverInfoSettings extends StatefulWidget {
  const CaregiverInfoSettings({super.key});

  @override
  State<CaregiverInfoSettings> createState() => _CaregiverInfoSettingsState();
}

class _CaregiverInfoSettingsState extends State<CaregiverInfoSettings> {
  String gender = 'Male';
  DateTime? dob;
  String relationship = 'Parent';
  String name = '';
  String email = '';
  String photoUrl = '';
  String patientName = '';
  bool _isLoading = false;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> relationshipOptions = ['Parent', 'Spouse', 'Sibling', 'Guardian', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
          relationship = userData['relationship'] ?? relationship;
          patientName = userData['patientName'] ?? patientName;
          dob = userData['dob'] != null
              ? DateTime.tryParse(userData['dob'])
              : dob;
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
          'relationship': relationship,
          'patientName': patientName,
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
          'Edit Caregiver Profile',
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
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Caregiver',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
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
                  
                  // Caregiving Information Section
                  _buildSectionHeader('Caregiving Information', Icons.family_restroom),
                  SizedBox(height: 16),
                  
                  _buildInfoTile(
                    icon: Icons.people,
                    title: 'Relationship to Patient',
                    value: relationship,
                    onTap: () => _showRelationshipDialog(),
                  ),
                  
                  SizedBox(height: 16),
                  
                  _buildPatientNameTile(),
                  
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

  Widget _buildPatientNameTile() {
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
              Icons.person_outline,
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
                  'Patient Name',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter patient name',
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
                  controller: TextEditingController(text: patientName),
                  onChanged: (val) => setState(() => patientName = val),
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

  Future<void> _showRelationshipDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Relationship',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: relationshipOptions.map((r) => 
            ListTile(
              title: Text(r),
              onTap: () => Navigator.pop(context, r),
              trailing: relationship == r ? Icon(Icons.check, color: Colors.redAccent) : null,
              contentPadding: EdgeInsets.zero,
            ),
          ).toList(),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (selected != null) setState(() => relationship = selected);
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
