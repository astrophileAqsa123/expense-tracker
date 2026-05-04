import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD

// --- COLOR PALETTE DEFINITION ---
const Color kStormyTeal = Color(0xFF156064); 
const Color kMintLeaf = Color(0xFF00C49A);

// Background and Accent Colors for this screen
const Color _kBackgroundColor = Color(0xFFFAFAFA); 
const Color _kAccentColor = kStormyTeal; 
const Color _kSuccessColor = kMintLeaf;
// --------------------------------
=======
>>>>>>> 0f10098 (Your commit message)

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final incomeCtrl = TextEditingController();

  String selectedCurrency = "USD";
  bool loading = false;
  bool _obscureText = true;

  final List<String> availableCurrencies = [
    "USD", "PKR", "EUR", "INR", "GBP", "JPY", "CAD"
  ];

  // Password validation
  bool isStrongPassword(String password) {
    // Requires minimum 6 characters, at least one uppercase letter, and at least one digit
    return RegExp(r'^(?=.*[A-Z])(?=.*\d).{6,}$').hasMatch(password);
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final auth = context.read<AuthService>();

      final user = await auth.register(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        income: double.parse(incomeCtrl.text.trim()),
        currency: selectedCurrency,
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Account created successfully!"),
            backgroundColor: _kSuccessColor, // Use Mint Leaf for success
          ),
        );

        Navigator.pushReplacementNamed(context, "/login");
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Signup failed!";
      switch (e.code) {
        case "email-already-in-use":
          msg = "Email already in use.";
          break;
        case "weak-password":
          msg = "Password is too weak.";
          break;
        case "invalid-email":
          msg = "Invalid email address.";
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

  // REFACTORED: Custom Text Field to match LoginScreen style
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
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: _kAccentColor.withOpacity(0.7)),
        prefixIcon: Icon(prefixIcon, color: _kAccentColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white, // Use white/light background for inputs
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
      validator: validator,
    );
  }

  // REFACTORED: Custom Dropdown to match Text Field style
  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: "Currency",
        labelStyle: TextStyle(color: _kAccentColor.withOpacity(0.7)),
        prefixIcon: const Icon(Icons.money, color: _kAccentColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kAccentColor, width: 2.0),
        ),
      ),
      items: availableCurrencies
          .map((c) => DropdownMenuItem(
                value: c, 
                child: Text(c, style: const TextStyle(color: Colors.black87)),
              ))
          .toList(),
      onChanged: (v) => setState(() => selectedCurrency = v!),
      validator: (v) => v == null ? "Required" : null,
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    incomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Create Account",
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
                // Icon (e.g., User/New Account icon)
                Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: _kAccentColor,
                ),
                const SizedBox(height: 30),

                // Name Field
                _buildTextField(
                  controller: nameCtrl,
                  labelText: "Full Name",
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? "Name required" : null,
                ),
                const SizedBox(height: 18),

                // Email Field
                _buildTextField(
                  controller: emailCtrl,
                  labelText: "Email",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains("@") ? null : "Invalid email",
                ),
                const SizedBox(height: 18),

                // Password Field
                _buildTextField(
                  controller: passCtrl,
                  labelText: "Password",
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureText,
                  validator: (v) =>
                      isStrongPassword(v!) ? null : "Min 6 chars, 1 uppercase & 1 number",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: _kAccentColor.withOpacity(0.6),
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                const SizedBox(height: 18),

                // Monthly Income Field
                _buildTextField(
                  controller: incomeCtrl,
                  labelText: "Monthly Income",
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v!.isEmpty || double.tryParse(v) == null)
                      ? "Enter valid income"
                      : null,
                ),
                const SizedBox(height: 18),

                // Currency Dropdown
                _buildCurrencyDropdown(),
                const SizedBox(height: 30),

                // Signup Button (Using the specified #156064 color)
                ElevatedButton(
                  onPressed: loading ? null : _handleSignup,
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
                          "Create Account",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
=======
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Account", style: TextStyle(fontSize: 16)),
>>>>>>> 0f10098 (Your commit message)
                ),
                const SizedBox(height: 10),

                // Login Link
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
                  child: Text(
                    "Already have an account? Login",
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