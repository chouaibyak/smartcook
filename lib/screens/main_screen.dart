import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'add_ingredient_screen.dart'; // Importe tes autres pages ici

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // On commence sur Inventory (index 1)

  // Liste des pages correspondant aux icônes de la barre
  final List<Widget> _pages = [
    const Center(child: Text("Home Page")),       // Index 0
    const AddIngredientScreen(),                  // Index 1 (Ta page actuelle)
    const Center(child: Text("Scan Page")),       // Index 2
    const Center(child: Text("Recipes Page")),    // Index 3
    const Center(child: Text("Shopping List")),   // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Le body change dynamiquement selon l'index
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // 2. On place la barre ICI, au niveau du parent
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // On change de page !
          });
        },
      ),
    );
  }
}