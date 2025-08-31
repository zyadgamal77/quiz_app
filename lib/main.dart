import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/theme/theme.dart';
import 'package:quiz_app/view/splash_screen/splash_screen.dart';
import 'firebase_options.dart';
import 'view/admin/admin_home_screen.dart';
import 'view/auth/login_screen.dart';
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
      routes: {
        '/auth': (context) => const AuthWrapper(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: authService.getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (roleSnapshot.hasData) {
                return roleSnapshot.data == 'admin'
                    ? const AdminHomeScreen()
                    : const HomeScreen();
              }
              return const LoginScreen(role: 'user');
            },
          );
        }
        return const LoginScreen(role: 'user');
      },
    );
  }
}
