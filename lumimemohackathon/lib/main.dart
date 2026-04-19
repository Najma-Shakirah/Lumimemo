import 'package:flutter/material.dart';
import 'apptheme.dart';
import 'authentication/loginscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import'authentication/dashboardscreen.dart';
import 'firebase_options.dart';
import 'splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LumimemoApp());
}

class LumimemoApp extends StatelessWidget {
  const LumimemoApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumimemo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
 
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while Firebase initializes
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            ),
          );
        }
 
        // Redirect based on auth state
        if (snapshot.hasData) {
          return const DashboardScreen(); // Logged in
        }
 
        return const LoginScreen(); // Not logged in
      },
    );
  }
}