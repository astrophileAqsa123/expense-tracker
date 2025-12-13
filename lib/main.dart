import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Services
import 'services/auth_service.dart';

// Theme
import 'theme/theme_provider.dart';

// Providers
import 'provider/transaction_provider.dart';
import 'provider/analytic_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/setting/setting.dart';
import 'screens/setting/profile_edit_screen.dart';
import 'screens/budget/advanced_budget_screen.dart';
import 'screens/analytics/analytics_screen.dart'; // ✅ ADD THIS
import 'screens/add_transaction/add_expense_screen.dart';

Future<void> main() async {
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
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        Provider<AuthService>(
          create: (_) => AuthService(),
          lazy: true,
        ),

        ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider(),
        ),

        ChangeNotifierProvider<AnalyticProvider>(
          create: (_) => AnalyticProvider(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode =
        context.select<ThemeProvider, ThemeMode>((p) => p.themeMode);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",

      themeMode: themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),

      initialRoute: "/splash",

      routes: {
        "/splash": (_) => const SplashScreen(),
        "/login": (_) => const LoginScreen(),
        "/signup": (_) => const SignupScreen(),
        "/dashboard": (_) => const DashboardScreen(),
        "/settings": (_) => const SettingsScreen(),
        "/profile_edit": (_) => const ProfileEditScreen(),
        "/advanced_budget": (_) => const AdvancedBudgetScreen(),
        "/analytics": (_) => const AnalyticsScreen(),
        "/expense": (_) => const AddExpenseScreen(),
      },
    );
  }
}
