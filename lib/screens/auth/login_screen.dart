import 'package:flutter/material.dart';
// import '../services/auth_service.dart'; // Uncomment this line when using the full project
// import '../models/user_model.dart'; // Uncomment this line when using the full project
// import 'package:cloud_firestore/cloud_firestore.dart'; // Uncomment this line when using the full project

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // final AuthService _authService = AuthService(); // Uncomment for full logic
  bool loading = false;
  bool _obscureText = true;

  // Placeholder for the actual login logic
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);

    // Simulate network delay and login attempt
    await Future.delayed(const Duration(seconds: 2));

    try {
      // **Original Logic (Uncomment and modify as needed):**
      /*
      final user = await _authService.login(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (user != null) {
        final userModel = await _getUserModel(user.uid);
        // Navigation and success logic
      } else {
        // Handle failed login (e.g., wrong credentials)
      }
      */

      // Placeholder success logic:
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login successful for: ${emailCtrl.text.trim()}"),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pushReplacementNamed(context, "/dashboard"); 
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }
  
  // // Original Firestore fetch logic (uncomment when using full project)
  // Future<UserModel?> _getUserModel(String uid) async {
  //   final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  //   if (!doc.exists) return null;

  //   return UserModel.fromMap(doc.id, doc.data()!);
  // }


  // --- Widget Builder for cleaner code ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon, color: Theme.of(context).primaryColor),
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should show a large, centered card or a simple form
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Login"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 40 : 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: loading
                    ? SizedBox(
                        height: 350, // Maintain space while loading
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Use minimum space required
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header Text for a professional look
                            const Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              "Please sign in to continue to your dashboard.",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),

                            // EMAIL
                            _buildTextField(
                              controller: emailCtrl,
                              labelText: "Email Address",
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v!.contains("@") ? null : "Enter a valid email address",
                            ),

                            const SizedBox(height: 15),

                            // PASSWORD
                            _buildTextField(
                              controller: passCtrl,
                              labelText: "Password",
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureText,
                              validator: (v) => v!.isEmpty ? "Password is required" : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 30),
                            
                            // LOGIN BUTTON
                            ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                // Use a primary color for a professional look
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 5,
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // SIGNUP BUTTON (Secondary Action)
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, "/signup"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Theme.of(context).primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Don't have an account? Sign up",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}