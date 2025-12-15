import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _loading = false;
  bool _sentOnce = false;
  String? _statusText; // ✅ shows success/error message on screen

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found for this email (user not registered).';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet/VPN.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled in Firebase Console.';
      default:
        return e.message ?? 'Something went wrong. Try again.';
    }
  }

  Future<void> _sendReset() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _emailCtrl.text.trim();

    setState(() {
      _loading = true;
      _statusText = null;
    });

    try {
      // ✅ Optional: set email language (example: English)
      FirebaseAuth.instance.setLanguageCode('en');

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      debugPrint("✅ Password reset email request sent for: $email");

      if (!mounted) return;
      setState(() {
        _sentOnce = true;
        _statusText =
            "Reset link request sent! Check Gmail Inbox + Spam + Promotions.\nEmail: $email";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reset link sent! Check your email.")),
      );
    } on FirebaseAuthException catch (e) {
      final msg = _friendlyMessage(e);
      debugPrint("❌ FirebaseAuthException: ${e.code} | ${e.message}");

      if (!mounted) return;
      setState(() => _statusText = "Error (${e.code}): $msg");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      debugPrint("❌ Unknown error: $e");
      if (!mounted) return;

      setState(() => _statusText = "Unknown error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error. Try again.")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Enter your email and we’ll send you a password reset link.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final email = (v ?? "").trim();
                    if (email.isEmpty) return "Email is required";
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                      return "Enter a valid email";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _sendReset,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_sentOnce ? "Resend Link" : "Send Reset Link"),
                  ),
                ),

                const SizedBox(height: 12),

                if (_statusText != null) ...[
                  Text(
                    _statusText!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],

                TextButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: const Text("Back to Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
