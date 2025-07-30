import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hemophilia_manager/auth/auth.dart';
import 'package:hemophilia_manager/services/firestore.dart';

class CreateAccPage extends StatefulWidget {
  const CreateAccPage({super.key});

  @override
  State<CreateAccPage> createState() => _CreateAccPageState();
}

class _CreateAccPageState extends State<CreateAccPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showRoleSelection = false;
  String? _createdUid;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await AuthService().createAccount(email, password);
      if (user != null) {
        _createdUid = user.uid;
        // Store user info in Firestore with temporary role
        await FirestoreService().createUser(user.uid, name, email, 'pending');
        setState(() {
          _showRoleSelection = true;
        });
      } else {
        _showError('Registration failed');
      }
    } catch (e) {
      _showError(e.toString());
    }
    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _selectRole(String role) async {
    if (_createdUid == null) return;
    setState(() => _isLoading = true);
    await FirestoreService().updateUser(_createdUid!, _nameController.text.trim(), _emailController.text.trim(), role);
    setState(() => _isLoading = false);

    // Navigate to appropriate screen
    if (role == 'medical') {
      Navigator.pushReplacementNamed(context, '/healthcare_main');
    } else if (role == 'caregiver') {
      Navigator.pushReplacementNamed(context, '/caregiver_main');
    } else {
      Navigator.pushReplacementNamed(context, '/user_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: !_showRoleSelection
                ? Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 12),
                        Image.asset('assets/images/app_logo.png', width: 80, height: 80),
                        SizedBox(height: 18),
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Join RedSyncPH and start managing your hemophilia care.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 28),
                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Enter name' : null,
                        ),
                        SizedBox(height: 18),
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter email';
                            if (!value.contains('@')) return 'Enter valid email';
                            return null;
                          },
                        ),
                        SizedBox(height: 18),
                        _buildInputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter password';
                            if (value.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        SizedBox(height: 18),
                        _buildInputField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Confirm your password';
                            if (value != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Register',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(color: Colors.black87, fontSize: 14),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      Text(
                        'Select Your Role',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 24),
                      _roleTile(
                        icon: FontAwesomeIcons.person,
                        title: 'I\'m a Patient',
                        subtitle: 'I want to track my own health',
                        color: Colors.redAccent,
                        onTap: () => _selectRole('patient'),
                      ),
                      SizedBox(height: 12),
                      _roleTile(
                        icon: FontAwesomeIcons.personBreastfeeding,
                        title: 'I\'m a Caregiver',
                        subtitle: 'I want to track someone else\'s health',
                        color: Colors.orangeAccent,
                        onTap: () => _selectRole('caregiver'),
                      ),
                      SizedBox(height: 12),
                      _roleTile(
                        icon: FontAwesomeIcons.userDoctor,
                        title: 'I\'m a Medical Professional',
                        subtitle: 'I want to track patients who have hemophilia',
                        color: Colors.blueAccent,
                        onTap: () => _selectRole('medical'),
                      ),
                      SizedBox(height: 24),
                      if (_isLoading)
                        Center(child: CircularProgressIndicator()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.redAccent),
        border: UnderlineInputBorder(),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _roleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: Icon(icon, size: 32, color: color),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 17),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.black87, fontSize: 14),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: color, size: 20),
      onTap: onTap,
    );
  }
}
