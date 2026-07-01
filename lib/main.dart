import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intern_connect/screens/splash_screen.dart';
import 'package:intern_connect/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const InternConnectApp());
}

class InternConnectApp extends StatelessWidget {
  const InternConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InternConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const SplashScreen(),
    );
  }
}
