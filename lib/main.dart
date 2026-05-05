import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcook/screens/add_ingredient_screen.dart';

import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const SmartCookApp());
}

class SmartCookApp extends StatelessWidget {
  const SmartCookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    );
  }
}