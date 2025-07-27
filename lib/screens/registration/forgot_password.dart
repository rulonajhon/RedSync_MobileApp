import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _sendResetEmail() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _message = 'Password reset email sent! Check your inbox.';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to send reset email: ${e.toString()}';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Temporary Empty AppBar
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/forgot-password.png', width: 250),
                SizedBox(height: 10),
                Text(
                  'Forgot your Password?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text('Enter your email address.', textAlign: TextAlign.center),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.redAccent,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _sendResetEmail,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Send Reset Email',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                if (_message != null) ...[
                  SizedBox(height: 18),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.startsWith('Password reset')
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
