import 'package:flutter/material.dart';
import 'dart:async';

/// Define app-specific gradient colors
class AppColors {
  static const Color primaryTeal = Color(0xFF00C896);
  static const Color primaryBlue = Color(0xFF0077B6);
  static const Color secondaryDark = Color(0xFF1D3557);
  static const Color lightBackground = Color(0xFFF1FAEE);
  static const Color midBackground = Color(0xFFE5E5E5);
}

/// SplashScreen displays app branding and navigates after a delay
class SplashScreen extends StatefulWidget {
  /// Route to navigate to after the splash
  static const String nextRoute = "/login";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  /// Starts a timer to navigate to the next screen
  void _navigateAfterDelay() {
    // Simulate initialization/loading if needed
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(SplashScreen.nextRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background
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
              // App Icon with gradient and shadow
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
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.ssid_chart,
                  color: Colors.white,
                  size: 72,
                ),
              ),

              const SizedBox(height: 32),

              // App Name
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

              // Tagline
              const Text(
                'Smart Money. Simple Tracking.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 80),

              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                strokeWidth: 3,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
