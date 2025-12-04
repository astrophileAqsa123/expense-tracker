import 'package:flutter/material.dart';
import 'dart:async'; // For using Timer

// Define the colors used in the app's modern gradient theme
class AppColors {
  static const Color primaryTeal = Color(0xFF00C896);
  static const Color primaryBlue = Color(0xFF0077B6);
  static const Color secondaryDark = Color(0xFF1D3557);
}

class SplashScreen extends StatefulWidget {
  // Define the route where the app should navigate after the splash duration
  static const String nextRoute = "/login"; // Assuming the Login Screen is next

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the timer to navigate after a delay
    _startAppInitialization();
  }

  void _startAppInitialization() {
    // Simulate any asynchronous loading tasks here (e.g., fetching user session)
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Navigate to the next screen, replacing the splash screen in the stack
        Navigator.of(context).pushReplacementNamed(SplashScreen.nextRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient background for a professional, branded look
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF1FAEE), // Very light background
              Color(0xFFE5E5E5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- App Icon (Simulated Gradient Icon) ---
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  // Gradient fill for the icon background
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryTeal, AppColors.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.ssid_chart, // Icon to represent a rising chart/flow
                  color: Colors.white,
                  size: 72,
                ),
              ),
              
              const SizedBox(height: 32),

              // --- App Name ---
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

              // --- Tagline ---
              const Text(
                'Smart Money. Simple Tracking.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 80),
              
              // Loading Indicator
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