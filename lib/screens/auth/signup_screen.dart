import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          const SnackBar(
            content: Text("Account created successfully!"),
            backgroundColor: Colors.green,
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
      ),
      validator: validator,
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      decoration: InputDecoration(
        labelText: "Currency",
        prefixIcon: Icon(Icons.money, color: Theme.of(context).primaryColor),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      items: availableCurrencies
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => selectedCurrency = v!),
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
      appBar: AppBar(title: const Text("Signup")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: nameCtrl,
                  labelText: "Full Name",
                  prefixIcon: Icons.person,
                  validator: (v) => v!.isEmpty ? "Name required" : null,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: emailCtrl,
                  labelText: "Email",
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains("@") ? null : "Invalid email",
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: passCtrl,
                  labelText: "Password",
                  prefixIcon: Icons.lock,
                  obscureText: _obscureText,
                  validator: (v) =>
                      isStrongPassword(v!) ? null : "Min 6 chars, 1 uppercase & 1 number",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: incomeCtrl,
                  labelText: "Monthly Income",
                  prefixIcon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v!.isEmpty || double.tryParse(v) == null)
                      ? "Enter valid income"
                      : null,
                ),
                const SizedBox(height: 15),
                _buildCurrencyDropdown(),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: loading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Account", style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
                  child: const Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
