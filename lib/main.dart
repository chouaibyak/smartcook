import 'package:flutter/material.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const SmartCookApp());
}

class SmartCookApp extends StatelessWidget {
  const SmartCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(),
    );
  }
}