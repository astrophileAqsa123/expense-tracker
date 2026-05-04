import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart';

// --- COLOR PALETTE DEFINITION ---
const Color kStormyTeal = Color(0xFF156064); 
const Color kMintLeaf = Color(0xFF00C49A);
const Color kRoyalGold = Color(0xFFF8E16C);
const Color kPowderBlush = Color(0xFFFFC2B4);
const Color kCoralGlow = Color(0xFFFB8F67);

// Background and Accent Colors for this screen
const Color _kBackgroundColor = Color(0xFFFAFAFA); 
const Color _kAccentColor = kStormyTeal; 
const Color _kSuccessColor = kMintLeaf;
// --------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  bool _obscureText = true;
  Future<void> _showForgotPasswordDialog() async {
    final resetEmailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: resetEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter your registered email",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              // Using kCoralGlow for an actionable color in the dialog
              style: ElevatedButton.styleFrom(backgroundColor: kCoralGlow),
              onPressed: () async {
                try {
                  final auth = context.read<AuthService>();

                  await auth.sendPasswordReset(
                    resetEmailCtrl.text.trim(),
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "Password reset email sent. Check your inbox.",
                        ),
                        backgroundColor: _kSuccessColor,
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  String msg = "Something went wrong";
                  if (e.code == "user-not-found") {
                    msg = "No user found with this email";
                  } else if (e.code == "invalid-email") {
                    msg = "Invalid email address";
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text("Send", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
<<<<<<< HEAD
=======
      // 🔹 Use Provider instead of creating AuthService
>>>>>>> 0f10098 (Your commit message)
      final auth = context.read<AuthService>();
      final user = await auth.login(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
          SnackBar(
            content: const Text("Login successful"),
            backgroundColor: _kSuccessColor,
=======
          const SnackBar(
            content: Text("Login successful"),
            backgroundColor: Colors.green,
>>>>>>> 0f10098 (Your commit message)
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Login failed!";
      switch (e.code) {
        case "wrong-password":
          msg = "Incorrect password";
          break;
        case "user-not-found":
          msg = "User not found";
          break;
        case "invalid-email":
          msg = "Invalid email";
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // Refactored to use Flat/Outline style
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    // The TextFormField now uses the Accent Color for focus and icons
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: _kAccentColor.withOpacity(0.7)),
        prefixIcon: Icon(prefixIcon, color: _kAccentColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white, // Use white/light background for inputs
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        // Use a simple OutlineInputBorder with rounded corners
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kAccentColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
    );
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Welcome Back",
          style: TextStyle(color: kStormyTeal, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _kBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon (e.g., Money/Wallet icon)
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: _kAccentColor,
                ),
                const SizedBox(height: 30),

                // Email Text Field
                _buildTextField(
                  controller: emailCtrl,
                  labelText: "Email Address",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),

                // Password Text Field
                _buildTextField(
                  controller: passCtrl,
                  labelText: "Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
<<<<<<< HEAD
                      color: _kAccentColor.withOpacity(0.6),
=======
>>>>>>> 0f10098 (Your commit message)
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                const SizedBox(height: 25),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                onPressed: () {
               Navigator.push(
                context,
             MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
              );
            },
            child: const Text("Forgot password?"),
          ),
        ),

                // Login Button (Using the specified #156064 color)
                ElevatedButton(
                  onPressed: loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                    backgroundColor: _kAccentColor, // Use #156064
                    foregroundColor: Colors.white, // White text on dark button
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5, // A subtle shadow for the button
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
=======
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login", style: TextStyle(fontSize: 16)),
>>>>>>> 0f10098 (Your commit message)
                ),
                const SizedBox(height: 10),

                // Sign Up Link
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, "/signup"),
                  child: Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: _kAccentColor.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}