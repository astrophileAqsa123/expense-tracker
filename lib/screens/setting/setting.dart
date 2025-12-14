import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Assuming these files exist and define the necessary providers/screens
import '../../theme/theme_provider.dart';
import '../../provider/currency_provider.dart';
import '../budget/advanced_budget_screen.dart';
import '../setting/profile_edit_screen.dart';

// --- THEME COLOR DEFINITIONS ---
// Use the same colors defined previously in the Dashboard
const Color kStormyTeal = Color(0xFF156064); 
const Color kCoralGlow = Color(0xFFFB8F67); 
const Color _kAccentColor = kStormyTeal; 
const Color _kDangerColor = kCoralGlow;
// -------------------------------

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = "English";

  final List<String> currencies = [
    "USD (\$)",
    "EUR (€)",
    "PKR (Rs)",
    "INR (₹)",
    "GBP (£)"
  ];

  final List<String> languages = [
    "English",
    "Urdu",
    "Hindi",
    "Arabic",
    "Spanish"
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    return Scaffold(
      // 🔹 THEMED APP BAR
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black87), // Dark text
        ),
        centerTitle: true,
        backgroundColor: Colors.white, // Clean white background
        elevation: 0, // Flat design
        iconTheme: const IconThemeData(color: Colors.black87), // Back button color
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
            // 🔹 THEMED DROPDOWN
            trailing: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
              ),
              child: DropdownButton<String>(
                value: selectedLanguage,
                iconEnabledColor: _kAccentColor,
                underline: const SizedBox(),
                onChanged: (val) => setState(() => selectedLanguage = val!),
                items: languages
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black87))))
                    .toList(),
              ),
            ),
          ),

          _tile(
            icon: Icons.currency_exchange,
            title: "Currency",
            subtitle: currencyProvider.label,
            // 🔹 THEMED DROPDOWN
            trailing: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
              ),
              child: DropdownButton<String>(
                value: currencyProvider.label,
                iconEnabledColor: _kAccentColor,
                underline: const SizedBox(),
                onChanged: (val) {
                  if (val != null) {
                    currencyProvider.setCurrency(val);
                  }
                },
                items: currencies
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black87))))
                    .toList(),
              ),
            ),
          ),

          _header("APPEARANCE"),

          // 🔹 THEMED SWITCH TILE
          SwitchListTile(
            secondary: Icon(Icons.dark_mode, color: _kAccentColor), // Stormy Teal icon
            title: const Text("Dark Mode", style: TextStyle(color: Colors.black87)),
            activeColor: _kAccentColor, // Stormy Teal switch color
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
            onTap: () {}, // Implement security settings later
          ),

          _header("ABOUT"),

          _tile(
            title: "About App",
            icon: Icons.info_outline,
            onTap: () {}, // Could navigate to About page
          ),

          const SizedBox(height: 20),

          // 🔹 THEMED LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kDangerColor, // Coral Glow for danger
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Match other card styles
                ),
                elevation: 0, // Flat
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  // Assuming '/login' is the route for the login screen
                  Navigator.pushReplacementNamed(context, "/login");
                }
              },
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ------------------- Helper Widgets -------------------
  // ✅ REFACTORED: Header (Subtle gray text)
  Widget _header(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8, left: 20),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600, // Slightly darker grey for better visibility
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 12,
          ),
        ),
      );

  // ✅ REFACTORED: Tile (Themed icon and arrow)
  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 26, color: _kAccentColor), // Stormy Teal icon
      title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: _kAccentColor), // Themed arrow
      onTap: onTap,
    );
  }
}