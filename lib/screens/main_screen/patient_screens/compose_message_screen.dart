import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared/chat_screen.dart';

class ComposeMessageScreen extends StatefulWidget {
  const ComposeMessageScreen({super.key});

  @override
  State<ComposeMessageScreen> createState() => _ComposeMessageScreenState();
}

class _ComposeMessageScreenState extends State<ComposeMessageScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _healthcareProviders = [];
  List<Map<String, dynamic>> _filteredProviders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthcareProviders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthcareProviders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get all users with role 'medical'
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'medical')
          .get();

      List<Map<String, dynamic>> providers = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        providers.add({'id': doc.id, 'uid': doc.id, ...data});
      }

      setState(() {
        _healthcareProviders = providers;
        _filteredProviders = providers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading healthcare providers: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load healthcare providers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterProviders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProviders = _healthcareProviders;
      } else {
        _filteredProviders = _healthcareProviders.where((provider) {
          final name = (provider['name'] ?? '').toString().toLowerCase();
          final email = (provider['email'] ?? '').toString().toLowerCase();
          final specialization = (provider['specialization'] ?? '')
              .toString()
              .toLowerCase();
          return name.contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase()) ||
              specialization.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _startChatWithProvider(Map<String, dynamic> provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          participant: {
            'id': provider['id'],
            'name': provider['name'],
            'role': provider['role'],
            'profilePicture': provider['profilePicture'],
            'specialization': provider['specialization'],
          },
          currentUserRole: 'patient',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Message',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterProviders,
                decoration: InputDecoration(
                  hintText: 'Search healthcare providers...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    color: Colors.grey.shade500,
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.userDoctor,
                  color: Colors.redAccent,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Select Healthcare Provider',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Healthcare Providers List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.redAccent),
                        SizedBox(height: 16),
                        Text(
                          'Loading healthcare providers...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredProviders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredProviders.length,
                    itemBuilder: (context, index) {
                      final provider = _filteredProviders[index];
                      return _buildProviderTile(provider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              FontAwesomeIcons.userDoctor,
              color: Colors.grey.shade400,
              size: 32,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No healthcare providers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderTile(Map<String, dynamic> provider) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.blue.shade100,
          backgroundImage: provider['profilePicture'] != null
              ? NetworkImage(provider['profilePicture'])
              : null,
          child: provider['profilePicture'] == null
              ? Icon(
                  FontAwesomeIcons.userDoctor,
                  color: Colors.blue.shade600,
                  size: 18,
                )
              : null,
        ),
        title: Text(
          provider['name'] ?? 'Unknown Provider',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            if (provider['specialization'] != null &&
                provider['specialization'].isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  provider['specialization'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(height: 6),
            if (provider['email'] != null && provider['email'].isNotEmpty)
              Text(
                provider['email'],
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.message, color: Colors.white, size: 14),
              SizedBox(width: 6),
              Text(
                'Message',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        onTap: () => _startChatWithProvider(provider),
      ),
    );
  }
}
