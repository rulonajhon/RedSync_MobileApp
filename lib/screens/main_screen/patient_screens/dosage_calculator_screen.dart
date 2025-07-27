import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore.dart';

class DosageCalculatorScreen extends StatefulWidget {
  const DosageCalculatorScreen({super.key});

  @override
  State<DosageCalculatorScreen> createState() => _DosageCalculatorScreenState();
}

class _DosageCalculatorScreenState extends State<DosageCalculatorScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController factorLevelController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  String selectedType = 'Hemophilia A';
  String userRole = '';
  String userHemophiliaType = '';
  bool isLoading = true;
  bool canEditHemophiliaType = false;
  double? result;

  final List<String> hemophiliaTypes = [
    'Hemophilia A',
    'Hemophilia B',
    'Hemophilia C',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // TODO: Add loading indicator while fetching user profile
  // TODO: Add error handling for network issues
  // TODO: Cache user profile data to avoid repeated API calls
  Future<void> _loadUserProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final userProfile = await _firestoreService.getUserProfile(uid);
        setState(() {
          if (userProfile != null) {
            userRole = userProfile['role'] ?? '';
            userHemophiliaType = userProfile['hemophiliaType'] ?? 'Hemophilia A';
            selectedType = userHemophiliaType;
            canEditHemophiliaType = userRole == 'caregiver';
          } else {
            // Handle case when profile doesn't exist
            userRole = '';
            userHemophiliaType = 'Hemophilia A';
            selectedType = 'Hemophilia A';
            canEditHemophiliaType = false;
          }
          isLoading = false;
        });
      } else {
        // Handle case when user is not logged in
        setState(() {
          userRole = '';
          userHemophiliaType = 'Hemophilia A';
          selectedType = 'Hemophilia A';
          canEditHemophiliaType = false;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        // Set defaults on error
        userRole = '';
        userHemophiliaType = 'Hemophilia A';
        selectedType = 'Hemophilia A';
        canEditHemophiliaType = false;
        isLoading = false;
      });
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile. Using default settings.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // TODO: Add more sophisticated dosage calculation formulas
  // TODO: Add safety warnings for high dosages
  // TODO: Save calculation history for future reference
  void calculateDosage() {
    final weight = double.tryParse(weightController.text);
    final factorLevel = double.tryParse(factorLevelController.text);

    if (weight == null || factorLevel == null) {
      setState(() {
        result = null;
      });
      return;
    }

    // Example calculation (replace with actual formula as needed)
    double dosage;
    if (selectedType == 'Hemophilia A') {
      dosage = weight * factorLevel * 0.5;
    } else if (selectedType == 'Hemophilia B') {
      dosage = weight * factorLevel * 1.0;
    } else if (selectedType == 'Hemophilia C') {
      dosage = weight * factorLevel * 0.7;
    } else {
      dosage = 0.0;
    }

    setState(() {
      result = dosage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Dosage Calculator',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
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
                    FontAwesomeIcons.calculator,
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
                        'Factor Dosage Calculator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Calculate your recommended factor dosage',
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
          ),

          // Content Section
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Result Display Section
                        _buildResultContainer(),
                        SizedBox(height: 24),

                        // Simple Parameters Section
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: weightController,
                                label: 'Weight (kg)',
                                icon: Icons.monitor_weight_outlined,
                                hint: 'Enter weight',
                                helperText: 'Body weight in kilograms',
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildInputField(
                                controller: factorLevelController,
                                label: 'Target Factor Level (%)',
                                icon: Icons.percent,
                                hint: 'Enter level',
                                helperText: 'Desired factor level (1-100%)',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildHemophiliaTypeSelector(),
                        
                        SizedBox(height: 24),

                        // Calculate Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: calculateDosage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: Icon(FontAwesomeIcons.calculator, size: 20),
                            label: Text(
                              'Calculate Dosage',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Information Section
                        if (!canEditHemophiliaType)
                          _buildInfoBanner(),

                        SizedBox(height: 24),

                        // Disclaimer Section
                        _buildDisclaimerSection(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContainer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calculate, color: Colors.green, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Recommended Dosage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: result == null
                ? Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Enter parameters and press calculate',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        '${result!.toStringAsFixed(2)} IU',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'For $selectedType',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.green, size: 20),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required String helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(icon, color: Colors.green),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          helperText,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHemophiliaTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hemophilia Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: canEditHemophiliaType ? Colors.grey.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: canEditHemophiliaType
              ? DropdownButtonFormField<String>(
                  value: selectedType,
                  items: hemophiliaTypes
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedType = val);
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.bloodtype, color: Colors.green),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.bloodtype, color: Colors.grey.shade500),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedType,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Icon(Icons.lock, color: Colors.grey.shade500, size: 20),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hemophilia Type Locked',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your hemophilia type is set based on your profile and cannot be changed. Only caregivers can modify this setting.',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Important Disclaimer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'This calculator provides estimates only. Always consult with your healthcare provider before making any changes to your treatment plan. Dosage requirements may vary based on individual factors.',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}