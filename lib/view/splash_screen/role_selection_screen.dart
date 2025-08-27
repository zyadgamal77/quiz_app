import 'package:flutter/material.dart';
import 'package:quiz_app/theme/theme.dart';
import 'package:quiz_app/view/auth/login_screen.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(role: role.toLowerCase()),
            ),
          );
        },
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
