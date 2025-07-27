import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore.dart';

class CareProviderScreen extends StatefulWidget {
  const CareProviderScreen({super.key});

  @override
  State<CareProviderScreen> createState() => _CareProviderScreenState();
}

class _CareProviderScreenState extends State<CareProviderScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();

  List<Map<String, dynamic>> _filteredProviders = [];
  bool _isSearching = false;

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredProviders = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final providers = await _firestoreService.searchHealthcareProviders(
        query,
      );
      setState(() {
        _filteredProviders = providers;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      _showError('Error searching providers: $e');
    }
  }

  void _addEmergencyContact() async {
    final contactPhone = _emergencyContactController.text.trim();
    if (contactPhone.isEmpty) {
      _showError('Please enter a phone number');
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _firestoreService.addEmergencyContact(uid, contactPhone);
        _emergencyContactController.clear();
        Navigator.of(context).pop();
        _showSuccess('Emergency contact added successfully');
      }
    } catch (e) {
      _showError('Error adding emergency contact: $e');
    }
  }

  void _editEmergencyContact(String contactId, String currentPhone) {
    _emergencyContactController.text = currentPhone;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Emergency Contact',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emergencyContactController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      prefixIcon: Icon(Icons.phone, color: Colors.redAccent),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final newPhone = _emergencyContactController.text
                                .trim();
                            if (newPhone.isNotEmpty) {
                              try {
                                await _firestoreService.updateEmergencyContact(
                                  contactId,
                                  newPhone,
                                );
                                _emergencyContactController.clear();
                                Navigator.of(context).pop();
                                _showSuccess(
                                  'Emergency contact updated successfully',
                                );
                              } catch (e) {
                                _showError(
                                  'Error updating emergency contact: $e',
                                );
                              }
                            }
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Contact'),
                                content: Text(
                                  'Are you sure you want to delete this emergency contact?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              try {
                                await _firestoreService.deleteEmergencyContact(
                                  contactId,
                                );
                                _showSuccess(
                                  'Emergency contact deleted successfully',
                                );
                              } catch (e) {
                                _showError(
                                  'Error deleting emergency contact: $e',
                                );
                              }
                            }
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Healthcare Providers',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Healthcare Providers'),
                  content: Text(
                    'Search for healthcare professionals by name to connect with them for your hemophilia care.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search healthcare providers by name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _searchController.text.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Results',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: _isSearching
                        ? Center(child: CircularProgressIndicator())
                        : _filteredProviders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No healthcare providers found',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Try searching with a different name',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredProviders.length,
                            itemBuilder: (context, index) {
                              final provider = _filteredProviders[index];
                              return ProviderListTile(provider: provider);
                            },
                          ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 24),
                    Text(
                      'Find Healthcare Providers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Use the search bar above to find healthcare professionals by their name',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tip',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Search for doctors, nurses, or specialists who can help with your hemophilia care',
                            style: TextStyle(color: Colors.blue.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "emergency_contact_fab", // Add unique heroTag
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (uid != null)
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestoreService.getEmergencyContacts(uid),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                  'Error loading contacts',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                              if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                // Sort contacts on client side by creation time if available
                                final contacts = snapshot.data!.docs.toList();
                                contacts.sort((a, b) {
                                  final dataA =
                                      a.data() as Map<String, dynamic>;
                                  final dataB =
                                      b.data() as Map<String, dynamic>;
                                  final timeA =
                                      dataA['createdAt'] as Timestamp?;
                                  final timeB =
                                      dataB['createdAt'] as Timestamp?;
                                  if (timeA != null && timeB != null) {
                                    return timeB.compareTo(
                                      timeA,
                                    ); // Descending order
                                  }
                                  return 0;
                                });

                                return Column(
                                  children: [
                                    ...contacts.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      return ListTile(
                                        leading: Icon(
                                          Icons.phone,
                                          color: Colors.redAccent,
                                        ),
                                        title: Text(data['contactPhone'] ?? ''),
                                        trailing: IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () =>
                                              _editEmergencyContact(
                                                doc.id,
                                                data['contactPhone'] ?? '',
                                              ),
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      );
                                    }),
                                    Divider(),
                                  ],
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        TextField(
                          controller: _emergencyContactController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter phone number',
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.redAccent,
                            ),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _addEmergencyContact,
                          child: Text(
                            'Add Contact',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        icon: Icon(FontAwesomeIcons.circlePlus),
        label: Text(
          'Emergency Contact',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class ProviderListTile extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderListTile({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          provider['name'] ?? 'Unknown Provider',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          provider['email'] ?? 'No email provided',
          style: TextStyle(color: Colors.grey[600]),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.local_hospital, color: Colors.white),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/care_user_information',
            arguments: provider,
          );
        },
      ),
    );
  }
}
