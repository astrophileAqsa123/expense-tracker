import 'package:flutter/material.dart';
// import '../services/auth_service.dart'; // Uncomment this line when using the full project

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  // final auth = AuthService(); // Uncomment this line when using the full project

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final incomeCtrl = TextEditingController();

  String selectedCurrency = "USD";
  bool loading = false;
  bool _obscureText = true;

  final List<String> availableCurrencies = ["USD", "EUR", "INR", "GBP", "JPY", "CAD"];

  // Strong password validation: at least 8 chars, 1 uppercase, 1 number
  bool isStrongPassword(String password) {
    return RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(password);
  }

  // Handle the registration logic
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => loading = true);

    // Placeholder for actual registration logic
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    try {
      // **Original Logic (Uncomment and replace placeholder):**
      /*
      await auth.register(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        income: double.parse(incomeCtrl.text.trim()),
        currency: selectedCurrency,
      );
      */
      
      // Placeholder success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
        // Navigator.pop(context); // Go back to login screen
        // In a real app, you would navigate to the home screen or login.
        print("Registration successful for: ${emailCtrl.text.trim()}");
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // --- Widget Builders for cleaner code ---

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

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      decoration: InputDecoration(
        labelText: "Preferred Currency",
        prefixIcon: Icon(Icons.money, color: Theme.of(context).primaryColor),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
      ),
      items: availableCurrencies
          .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c, style: const TextStyle(fontSize: 16)),
              ))
          .toList(),
      onChanged: (v) => setState(() {
        selectedCurrency = v!;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should show a large, centered card or a simple form
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Your Account"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 40 : 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: loading
                    ? SizedBox(
                        height: 400, // Maintain space while loading
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
                            // Header Text for a modern look
                            const Text(
                              "Welcome!",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Text(
                              "Set up your profile to start tracking your finances.",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),

                            // NAME
                            _buildTextField(
                              controller: nameCtrl,
                              labelText: "Full Name",
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v!.isEmpty ? "Name is required" : null,
                            ),

                            const SizedBox(height: 15),

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
                              validator: (v) => isStrongPassword(v!)
                                  ? null
                                  : "Min 8 chars, 1 uppercase & 1 number",
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
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0, bottom: 15.0),
                              child: Text(
                                "Password requires at least 8 characters, 1 uppercase letter, and 1 number.",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),

                            // INCOME
                            _buildTextField(
                              controller: incomeCtrl,
                              labelText: "Monthly Income",
                              prefixIcon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v!.isEmpty) return "Income is required";
                                if (double.tryParse(v) == null) return "Enter a valid number";
                                return null;
                              },
                            ),

                            const SizedBox(height: 15),

                            // CURRENCY DROPDOWN
                            _buildCurrencyDropdown(),

                            const SizedBox(height: 30),

                            // SIGNUP BUTTON
                            ElevatedButton(
                              onPressed: _handleSignup,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                // Use a primary color for a professional look
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                "Create Account",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // LOGIN BUTTON (Secondary Action)
                            OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, "/login"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: Theme.of(context).primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Already have an account? Login",
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