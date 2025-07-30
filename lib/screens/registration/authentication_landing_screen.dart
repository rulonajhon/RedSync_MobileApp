import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hemophilia_manager/auth/auth.dart';

class AuthenticationLandingScreen extends StatefulWidget {
  const AuthenticationLandingScreen({super.key});

  @override
  State<AuthenticationLandingScreen> createState() => _AuthenticationLandingScreenState();
}

class _AuthenticationLandingScreenState extends State<AuthenticationLandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and App Name Section
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/app_logo.png',
                            width: 100,
                            height: 100,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'RedSyncPH',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Your hemophilia management companion',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Authentication Options Section
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Primary Actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              title: 'Login',
                              icon: Icons.login,
                              isPrimary: true,
                              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              title: 'Register',
                              icon: Icons.person_add,
                              isPrimary: true,
                              onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Divider with text
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      
                      // Google Sign In
                      SizedBox(
                        width: double.infinity,
                        child: _buildSocialButton(
                          title: 'Sign in with Google',
                          icon: FontAwesomeIcons.google,
                          iconColor: Colors.redAccent,
                          onTap: () {
                            // TODO: Implement Google Sign In
                          },
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Guest Access
                      SizedBox(
                        width: double.infinity,
                        child: _buildActionButton(
                          title: 'Continue as Guest',
                          icon: Icons.person_outline,
                          isPrimary: false,
                          onTap: () async {
                            try {
                              await AuthService().signInAnonymously();
                              if (mounted) {
                                Navigator.pushReplacementNamed(context, '/user_screen');
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to continue as guest'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      
                      SizedBox(height: 12),
                      
                      // Pre-screening Button
                      SizedBox(
                        width: double.infinity,
                        child: _buildActionButton(
                          title: 'Take Pre-screening Test',
                          icon: Icons.quiz_outlined,
                          isPrimary: false,
                          onTap: () {
                            Navigator.pushNamed(context, '/pre_screening');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Text(
                      'By continuing, you agree to our',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to Terms of Service
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Terms of Service',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          ' and ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to Privacy Policy
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
          color: isPrimary ? Colors.white : Colors.grey.shade700,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isPrimary ? Colors.white : Colors.grey.shade700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.redAccent : Colors.grey.shade100,
          foregroundColor: isPrimary ? Colors.white : Colors.grey.shade700,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPrimary ? Colors.redAccent : Colors.grey.shade300,
              width: 1,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
