import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hemophilia_manager/services/firestore.dart'; // Update with your actual import


class CareUserInformationScreen extends StatefulWidget {
  const CareUserInformationScreen({super.key});

  @override
  State<CareUserInformationScreen> createState() =>
      _CareUserInformationScreenState();
}

class _CareUserInformationScreenState extends State<CareUserInformationScreen> {
  bool _shareData = false;
  bool _isLoading = false;

  Future<void> _toggleDataSharing(bool value) async {
    setState(() => _isLoading = true);
    
    try {
      final provider = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (provider == null || currentUser == null) {
        throw Exception('Missing provider or user information');
      }

      if (value) {
        // Send data sharing request
        await FirebaseFirestore.instance.collection('data_sharing_requests').add({
          'patientUid': currentUser.uid,
          'providerUid': provider['id'],
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Send notification to provider
        await FirestoreService().createNotification(
          provider['id'],
          'New data sharing request from ${currentUser.email ?? 'a patient'}',
        );

        _showSnackBar('Data sharing request sent successfully!', Colors.green);
      } else {
        // Remove data sharing
        final existingSharing = await FirebaseFirestore.instance
            .collection('data_sharing')
            .where('patientUid', isEqualTo: currentUser.uid)
            .where('providerUid', isEqualTo: provider['id'])
            .where('active', isEqualTo: true)
            .get();

        if (existingSharing.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('data_sharing')
              .doc(existingSharing.docs.first.id)
              .update({'active': false});
          
          _showSnackBar('Data sharing disabled', Colors.orange);
        }
      }

      setState(() => _shareData = value);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkExistingDataSharing();
  }

  Future<void> _checkExistingDataSharing() async {
    try {
      final provider = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (provider != null && currentUser != null) {
        final existingSharing = await FirebaseFirestore.instance
            .collection('data_sharing')
            .where('patientUid', isEqualTo: currentUser.uid)
            .where('providerUid', isEqualTo: provider['id'])
            .where('active', isEqualTo: true)
            .get();

        if (existingSharing.docs.isNotEmpty) {
          setState(() => _shareData = true);
        }
      }
    } catch (e) {
      print('Error checking existing data sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Provider Information',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.redAccent,
              child: Icon(
                Icons.local_hospital,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              provider?['name'] ?? 'Unknown Provider',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              provider?['email'] ?? 'No email provided',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Healthcare Professional',
              style: TextStyle(
                fontSize: 14,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.share, color: Colors.redAccent),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Share My Data',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'with ${provider?['name'] ?? 'this provider'}',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Switch(
                                    value: _shareData,
                                    onChanged: _toggleDataSharing,
                                    activeColor: Colors.redAccent,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.redAccent),
                    title: Text(
                      'How does sharing my data work?',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(FontAwesomeIcons.angleRight, color: Colors.redAccent),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Data Sharing Information'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('When you share your data:'),
                              SizedBox(height: 8),
                              Text('• Your bleed logs will be visible to this provider'),
                              Text('• Your medication history will be shared'),
                              Text('• Your dosage calculations will be accessible'),
                              Text('• You can revoke access at any time'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Got it'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Divider(color: Colors.grey.shade300),
                  ListTile(
                    leading: Icon(Icons.email_outlined, color: Colors.redAccent),
                    title: Text(
                      'Contact Provider',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(provider?['email'] ?? 'No email available'),
                    trailing: Icon(FontAwesomeIcons.angleRight, color: Colors.redAccent),
                    onTap: () {
                      // TODO: Implement email functionality
                    },
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
