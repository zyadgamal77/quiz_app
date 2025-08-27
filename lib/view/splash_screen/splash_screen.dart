import 'package:flutter/material.dart';
import 'package:quiz_app/view/splash_screen/role_selection_screen.dart';
import '../../theme/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    // Start the animation
    _controller.forward();

    // Navigate after animation completes
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RoleSelectionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutQuart;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0069ca),
      body: Stack(
        children: [
          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Logo
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(
                              0.0,
                              0.5,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                        ),
                        child: Container(
                          child: Image.asset(
                            'assets/images/splash.jpg',
                            height: 300,
                            width: 300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // App Name with Animation
                      FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(
                              0.5,
                              1.0,
                              curve: Curves.easeIn,
                            ),
                          ),
                        ),
                        child: Transform.rotate(
                          angle: -0.05,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              // borderRadius: BorderRadius.circular(50),
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xffe6f3ff)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Text(
                              'Smart Quiz',
                              style: TextStyle(
                                color: const Color(0xff0069ca),
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Loading Indicator
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
