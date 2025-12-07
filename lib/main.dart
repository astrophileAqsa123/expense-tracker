import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'theme/theme_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

import 'screens/setting/setting.dart';
import 'screens/setting/profile_edit_screen.dart';
import 'screens/budget/advanced_budget_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",

      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      initialRoute: "/splash",

      routes: {
        "/splash": (_) => const SplashScreen(),
        "/login": (_) => const LoginScreen(),
        "/signup": (_) => const SignupScreen(),
        "/dashboard": (_) => const DashboardScreen(),
        "/settings": (_) => const SettingsScreen(),
        "/profile_edit": (_) => const ProfileEditScreen(),
        "/advanced_budget": (_) => const AdvancedBudgetScreen(),
      },
    );
  }
}
