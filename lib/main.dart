import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/lead_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qyauahekazhtokqwlzzf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5YXVhaGVrYXpodG9rcXdsenpmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMDEzMTUsImV4cCI6MjA5MjY3NzMxNX0.334or9i2Cg633-EYHWR_ErjOaFy_sv5kHI1Qum7hLzk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Property CRM',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1E3A8A),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E3A8A),
          titleTextStyle: TextStyle(
            color: Color(0xFF1E3A8A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/leads': (context) => const LeadList(),
      },
    );
  }
}