import 'package:flutter/material.dart';
import 'package:quiz_app/theme/theme.dart';
import 'package:quiz_app/view/auth/auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
            const SizedBox(height: 70),
            const Text(
              'Please Select Your Role',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
            ),
            const SizedBox(height: 50),
            _buildRoleButton(
              context,
              'Admin',
              Icons.admin_panel_settings,
              'Access admin dashboard and manage quizzes',
            ),
            const SizedBox(height: 20),
            _buildRoleButton(
              context,
              'User',
              Icons.person,
              'Take quizzes and track your progress',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String role,
    IconData icon,
    String description,
  ) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AuthScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.grey.withOpacity(0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 15),
            Text(
              role,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
