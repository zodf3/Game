import 'package:flutter/material.dart';
import 'ui/profile_setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TwentyNineApp());
}

class TwentyNineApp extends StatelessWidget {
  const TwentyNineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '29 Card Game - Reverse & Bluetooth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const ProfileSetupScreen(),
    );
  }
}
