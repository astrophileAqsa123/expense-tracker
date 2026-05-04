import 'dart:async';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';

=======
import 'dart:async';

/// Define app-specific gradient colors
>>>>>>> 0f10098 (Your commit message)
class AppColors {
  static const Color primaryTeal = Color(0xFF00C896);
  static const Color primaryBlue = Color(0xFF0077B6);
  static const Color secondaryDark = Color(0xFF1D3557);
  static const Color lightBackground = Color(0xFFF1FAEE);
  static const Color midBackground = Color(0xFFE5E5E5);
}

/// SplashScreen displays app branding and navigates after a delay
class SplashScreen extends StatefulWidget {
<<<<<<< HEAD
=======
  /// Route to navigate to after the splash
  static const String nextRoute = "/login";

>>>>>>> 0f10098 (Your commit message)
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _goNext();
  }

  void _goNext() {
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
    
        Navigator.pushReplacementNamed(context, "/dashboard");
      } else {
   
        Navigator.pushReplacementNamed(context, "/login");
=======
    _navigateAfterDelay();
  }

  /// Starts a timer to navigate to the next screen
  void _navigateAfterDelay() {
    // Simulate initialization/loading if needed
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(SplashScreen.nextRoute);
>>>>>>> 0f10098 (Your commit message)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
=======
      // Gradient background
>>>>>>> 0f10098 (Your commit message)
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightBackground, AppColors.midBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
<<<<<<< HEAD
=======
              // App Icon with gradient and shadow
>>>>>>> 0f10098 (Your commit message)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryTeal, AppColors.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
<<<<<<< HEAD
                      offset: const Offset(0, 10),
=======
                      offset: Offset(0, 10),
>>>>>>> 0f10098 (Your commit message)
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.ssid_chart,
                  color: Colors.white,
                  size: 72,
                ),
              ),
<<<<<<< HEAD
              const SizedBox(height: 32),
=======

              const SizedBox(height: 32),

              // App Name
>>>>>>> 0f10098 (Your commit message)
              const Text(
                'Expense Tracker',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondaryDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
<<<<<<< HEAD
=======

              // Tagline
>>>>>>> 0f10098 (Your commit message)
              const Text(
                'Smart Money. Simple Tracking.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 80),
<<<<<<< HEAD
              const CircularProgressIndicator(
=======

              // Loading indicator
              CircularProgressIndicator(
>>>>>>> 0f10098 (Your commit message)
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
