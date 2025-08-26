import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class AuthUtils {
  // Check if current user is admin
  static Future<bool> isAdmin(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final role = await authService.getUserRole();
    return role == 'admin';
  }

  // Show access denied dialog
  static void showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text('You do not have permission to access this page.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
          ),
        ],
      ),
    );
  }

  // Check admin access and show dialog if not admin
  static Future<bool> checkAdminAccess(BuildContext context) async {
    final isUserAdmin = await isAdmin(context);
    if (!isUserAdmin) {
      showAccessDeniedDialog(context);
      return false;
    }
    return true;
  }
}
