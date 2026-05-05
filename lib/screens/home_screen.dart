import 'package:flutter/material.dart';

import 'inventory_screen.dart';
import 'barcode_scan_screen.dart';
import 'recipe_results_screen.dart';
import 'shopping_list_screen.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

 // home_screen.dart

final List<Widget> pages = const [
  Center(child: Text("Welcome Home Page")),
  InventoryPage(), 
 ScanPage(),
  RecipesPage(),
 ListPage(),
];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: onTabTapped,
      ),
    );
  }
}