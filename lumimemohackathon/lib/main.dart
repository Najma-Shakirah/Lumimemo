import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'apptheme.dart';
import 'authentication/loginscreen.dart';
import 'firebase_options.dart';

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
      title: 'MemoryBridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const LoginScreen(),
    );
  }
}