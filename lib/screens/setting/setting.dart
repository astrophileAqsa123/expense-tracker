import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/theme_provider.dart';
import '../../provider/currency_provider.dart';
import '../../provider/locale_provider.dart'; // ✅ NEW
import '../../l10n/app_localizations.dart'; // ✅ NEW (generated)

import '../budget/advanced_budget_screen.dart';
import '../setting/profile_edit_screen.dart';
import '../security/security_screen.dart';


// ✅ Make sure THIS path matches your project structure
import 'app_lock_and_permissions.dart';

// --- THEME COLOR DEFINITIONS ---
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
  // We will sync this with LocaleProvider so dropdown matches current app language
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

  // ✅ Map dropdown label -> Locale
  final Map<String, Locale> _languageToLocale = const {
    "English": Locale('en'),
    "Urdu": Locale('ur'),
    "Hindi": Locale('hi'),
    "Arabic": Locale('ar'),
    "Spanish": Locale('es'),
  };

  // ✅ Map Locale -> dropdown label (for initial selection)
  String _labelFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ur':
        return "Urdu";
      case 'hi':
        return "Hindi";
      case 'ar':
        return "Arabic";
      case 'es':
        return "Spanish";
      case 'en':
      default:
        return "English";
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync dropdown with current app locale
    final currentLocale = context.watch<LocaleProvider>().locale;
    final newLabel = _labelFromLocale(currentLocale);
    if (selectedLanguage != newLabel) {
      selectedLanguage = newLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    // ✅ Localized strings
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings, // ✅ localized
          style: const TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _header(t.general), // ✅ localized

          _tile(
            title: t.account, // ✅ localized
            subtitle: t.accountSubtitle, // ✅ localized
            icon: Icons.person_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
            ),
          ),

          _tile(
            icon: Icons.language,
            title: t.language, // ✅ localized
            subtitle: selectedLanguage,
            trailing: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.white),
              child: DropdownButton<String>(
                value: selectedLanguage,
                iconEnabledColor: _kAccentColor,
                underline: const SizedBox(),
                onChanged: (val) {
                  if (val == null) return;

                  setState(() => selectedLanguage = val);

                  final locale = _languageToLocale[val] ?? const Locale('en');

                  // ✅ THIS CHANGES THE WHOLE APP LANGUAGE
                  context.read<LocaleProvider>().setLocale(locale);
                },
                items: languages
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          _tile(
            icon: Icons.currency_exchange,
            title: t.currency, // ✅ localized
            subtitle: currencyProvider.label,
            trailing: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.white),
              child: DropdownButton<String>(
                value: currencyProvider.label,
                iconEnabledColor: _kAccentColor,
                underline: const SizedBox(),
                onChanged: (val) {
                  if (val != null) currencyProvider.setCurrency(val);
                },
                items: currencies
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          _header(t.appearance), // ✅ localized

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: _kAccentColor),
            title: Text(
              t.darkMode, // ✅ localized
              style: const TextStyle(color: Colors.black87),
            ),
            activeColor: _kAccentColor,
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (val) => themeProvider.toggleTheme(val),
          ),

          _header(t.budgetFeatures), // ✅ localized

          _tile(
            title: t.advancedBudgetSetup, // ✅ localized
            subtitle: t.advancedBudgetSubtitle, // ✅ localized
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvancedBudgetScreen()),
            ),
          ),

          _header(t.security), // ✅ localized

          _tile(
            title: t.privacySecurity, // ✅ localized
            subtitle: t.privacySecuritySubtitle, // ✅ localized
            icon: Icons.lock_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AppLockAndPermissionsGate(
                  lockOnStart: true,
                  enabled: true,
                  lockAfter: const Duration(seconds: 10),
                  child: const _SecurityPermissionsPage(),
                ),
              ),
            ),
          ),

          _header(t.about), // ✅ localized

          _tile(
            title: t.aboutApp, // ✅ localized
            icon: Icons.info_outline,
            onTap: () {},
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kDangerColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, "/login");
                }
              },
              child: Text(
                t.logout, // ✅ localized
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ------------------- Helper Widgets -------------------
  Widget _header(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8, left: 20),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 12,
          ),
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
      leading: Icon(icon, size: 26, color: _kAccentColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600))
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right, size: 20, color: _kAccentColor),
      onTap: onTap,
    );
  }
}

/// ✅ This is the page user sees AFTER unlocking.
/// Tip: To translate this page too, replace hardcoded strings with AppLocalizations keys.
class _SecurityPermissionsPage extends StatelessWidget {
  const _SecurityPermissionsPage();

  @override
  Widget build(BuildContext context) {
    // If you add keys for these, you can localize them too.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Security & Permissions"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
  "App Security",
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
const SizedBox(height: 12),
Card(
  child: ListTile(
    leading: const Icon(Icons.delete_outline, color: Colors.red),
    title: const Text("Remove App PIN"),
    subtitle: const Text("Disable app lock PIN"),
    trailing: const Icon(Icons.chevron_right),
    onTap: () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Remove PIN?"),
          content: const Text(
            "This will disable PIN protection. You can still use biometrics if available.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Remove"),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await AppLockAndPermissionsGate.clearPin();

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("App PIN removed"),
            backgroundColor: Colors.green,
          ),
        );
      }
    },
  ),
),


Card(
  child: ListTile(
    leading: const Icon(Icons.pin, color: _kAccentColor),
    title: const Text("Change App PIN"),
    subtitle: const Text("Update or reset your app lock PIN"),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SecurityAndPermissionsScreen(),
        ),
      );
    },
  ),
),

const SizedBox(height: 20),
const Divider(),
const SizedBox(height: 10),

          const Text(
            "Permissions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _permTile(
            context,
            icon: Icons.camera_alt,
            title: "Camera",
            subtitle: "Allow camera access (receipt scan, profile photo)",
            onTap: () => AppLockAndPermissionsGate.requestCamera(context),
          ),
          _permTile(
            context,
            icon: Icons.mic,
            title: "Microphone",
            subtitle: "Allow microphone access",
            onTap: () => AppLockAndPermissionsGate.requestMicrophone(context),
          ),
          _permTile(
            context,
            icon: Icons.photo_library,
            title: "Photos / Storage",
            subtitle: "Allow gallery access",
            onTap: () => AppLockAndPermissionsGate.requestPhotosOrStorage(context),
          ),
          _permTile(
            context,
            icon: Icons.notifications,
            title: "Notifications",
            subtitle: "Allow alerts & reminders",
            onTap: () => AppLockAndPermissionsGate.requestNotifications(context),
          ),
          _permTile(
            context,
            icon: Icons.location_on,
            title: "Location",
            subtitle: "Allow location (optional)",
            onTap: () => AppLockAndPermissionsGate.requestLocation(context),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          const Text(
            "Tip",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "If permission is permanently denied, open Settings and enable it manually.",
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _permTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Future<bool> Function() onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: _kAccentColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await onTap();
        },
      ),
    );
  }
}
