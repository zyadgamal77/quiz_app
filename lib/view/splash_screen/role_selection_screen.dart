import 'package:flutter/material.dart';
import 'package:quiz_app/theme/theme.dart';
import 'package:quiz_app/view/auth/login_screen.dart';
import 'package:quiz_app/view/auth/signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Smart Quiz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Welcome to our App',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildRoleButton(
                  title: 'Tap to login',
                  icon: Icons.login,
                  onPressed: () => _navigateToAuth(context, isLogin: true),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }

  void _navigateToAuth(BuildContext context, {required bool isLogin}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isLogin
            ? const LoginScreen(role: '',)
            : const SignupScreen(role: '',),
      ),
    );
  }
}
