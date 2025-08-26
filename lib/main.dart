import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/theme/theme.dart';
import 'package:quiz_app/view/splash_screen/role_selection_screen.dart';
import 'package:quiz_app/view/splash_screen/splash_screen.dart';
import 'firebase_options.dart';
import 'view/admin/admin_home_screen.dart';
import 'view/user/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Quiz',
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint('Auth state changed. Has data: ${snapshot.hasData}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('Waiting for auth state...');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is logged in, check their role and navigate accordingly
        if (snapshot.hasData) {
          debugPrint('User is logged in. UID: ${snapshot.data?.uid}');
          
          return FutureBuilder<String?>(
            future: authService.getUserRole(),
            builder: (context, roleSnapshot) {
              debugPrint('Role snapshot state: ${roleSnapshot.connectionState}');
              
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                debugPrint('Waiting for user role...');
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final role = roleSnapshot.data;
              debugPrint('User role determined: $role');
              
              if (role == 'admin') {
                debugPrint('Navigating to AdminHomeScreen');
                return const AdminHomeScreen();
              } else {
                debugPrint('Navigating to HomeScreen');
                return const HomeScreen();
              }
            },
          );
        }

        // If user is not logged in, show the role selection screen
        return const SplashScreen();
      },
    );
  }
}
