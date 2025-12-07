import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/theme_provider.dart';
import '../budget/advanced_budget_screen.dart';
import '../setting/profile_edit_screen.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  String selectedCurrency = "USD (\$)";
  String selectedLanguage = "English";

  final List<String> currencies = ["USD (\$)", "EUR (€)", "PKR (Rs)", "INR (₹)", "GBP (£)"];
  final List<String> languages = ["English", "Urdu", "Hindi", "Arabic", "Spanish"];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _header("GENERAL"),

          _tile(
            title: "Account",
            subtitle: "Profile, password",
            icon: Icons.person_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ),
          ),

          _tile(
            icon: Icons.language,
            title: "Language",
            subtitle: selectedLanguage,
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (val) => setState(() => selectedLanguage = val!),
              items: languages.map((e) =>
                  DropdownMenuItem(value: e, child: Text(e))).toList(),
            ),
          ),

          _tile(
            icon: Icons.currency_exchange,
            title: "Currency",
            subtitle: selectedCurrency,
            trailing: DropdownButton<String>(
              value: selectedCurrency,
              onChanged: (val) => setState(() => selectedCurrency = val!),
              items: currencies.map((e) =>
                  DropdownMenuItem(value: e, child: Text(e))).toList(),
            ),
          ),

          _header("APPEARANCE"),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),

          _header("BUDGET FEATURES"),

          _tile(
            title: "Advanced Budget Setup",
            subtitle: "AI predictions & auto-category",
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvancedBudgetScreen()),
            ),
          ),

          _header("SECURITY"),

          _tile(
            title: "Privacy & Security",
            subtitle: "App lock, permissions",
            icon: Icons.lock_outline,
            onTap: () {},
          ),

          _header("ABOUT"),

          _tile(
            title: "About App",
            icon: Icons.info_outline,
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: const Text("Logout"),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _header(String text) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      text,
      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
    ),
  );

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 26, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
