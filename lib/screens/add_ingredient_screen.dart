// lib/screens/add_ingredient_screen.dart
import 'package:flutter/material.dart';

class AddIngredientScreen extends StatelessWidget {
  const AddIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un aliment'),
        backgroundColor: const Color.fromARGB(255, 10, 49, 11),
      ),
      body: const Center(
        child: Text(
          'Welcome to Add Ingredient Page',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}