import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/ingredient_provider.dart';
import '../providers/recipe_provider.dart';

import 'inventory_screen.dart';
import 'add_ingredient_screen.dart';
import 'barcode_scan_screen.dart';
import 'ai_scan_screen.dart';
import 'recipe_results_screen.dart';
import 'shopping_list_screen.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? result;

  const HomeScreen({super.key, this.result});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Exécute le chargement des ingrédients
    // après l'initialisation complète du widget
    Future.microtask(() async {
      // Récupération du provider des ingrédients
      final ingredientProvider = Provider.of<IngredientProvider>(
        context,
        listen: false,
      );

      // Récupération du provider des recettes
      final recipeProvider = Provider.of<RecipeProvider>(
        context,
        listen: false,
      );

      // Charger les ingrédients depuis l'API/backend
      await ingredientProvider.fetchIngredients();

      // Générer les suggestions de recettes
      // selon les ingrédients disponibles
      recipeProvider.generateSuggestions(ingredientProvider.ingredients);
    });

    // Liste des pages utilisées dans IndexedStack
    final pages = [
      HomePage(result: widget.result, onNavigate: onTabTapped),

      const InventoryPage(), // 1
      const BarcodeScanScreen(), // 2
      const RecipesPage(), // 3
      const ListPage(), // 4

      AddIngredientScreen(
        // 5
        onSave: () async {
          await Provider.of<IngredientProvider>(
            context,
            listen: false,
          ).fetchIngredients();

          onTabTapped(1);
        },
      ),

      const AiScanScreen(), // 6
    ];
  }

  // Fonction utilisée pour changer la page affichée
  void onTabTapped(int index) {
    setState(() {
      // Met à jour l'index courant
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(result: widget.result, onNavigate: onTabTapped),
      const InventoryPage(),
      const BarcodeScanScreen(),
      const RecipesPage(),
      const ListPage(),

      AddIngredientScreen(
        onSave: () async {
          await Provider.of<IngredientProvider>(
            context,
            listen: false,
          ).fetchIngredients();

          onTabTapped(1);
        },
      ),

      const AiScanScreen(),
    ];

    final bottomNavIndex = currentIndex <= 4 ? currentIndex : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomAppBar(),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: bottomNavIndex,
        onTap: onTabTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Map<String, dynamic>? result;
  final Function(int) onNavigate;

  const HomePage({super.key, this.result, required this.onNavigate});

  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final username = result?['user']?['nom'] ?? 'Guest';
    final ingredientProvider = Provider.of<IngredientProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    final inventoryCount = ingredientProvider.totalItems;
    final expiringSoonCount = ingredientProvider.expiringSoonCount;
    final missingCount = ingredientProvider.missingCount;
    final inventoryProgress = ingredientProvider.inventoryProgress;

    final suggestedRecipe = recipeProvider.firstSuggestedRecipe;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, $username",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Your kitchen is ready for some magic today.",
            style: TextStyle(fontSize: 14, color: textLight, height: 1.4),
          ),

          const SizedBox(height: 24),

          HomeSummaryCard(
            title: "Inventory",
            value: "$inventoryCount Items",
            icon: Icons.inventory_2_outlined,
            progress: inventoryProgress,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryPage()),
              );
            },
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: HomeAlertCard(
                  title: "Expiring Soon",
                  number: "$expiringSoonCount",
                  subtitle: "Items expire today",
                  icon: Icons.timer_outlined,
                  backgroundColor: const Color(0xFFFFEAE6),
                  contentColor: const Color(0xFFC0392B),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: HomeAlertCard(
                  title: "Missing",
                  number: "$missingCount",
                  subtitle: "For tonight's Pasta",
                  icon: Icons.shopping_basket_outlined,
                  backgroundColor: const Color(0xFFFF9F43),
                  contentColor: const Color(0xFF5A2200),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          const SectionTitle(title: "Quick Actions"),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  title: "Add ingredient",
                  icon: Icons.add_circle_outline,
                  onTap: () => onNavigate(5),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: QuickActionButton(
                  title: "Scan barcode",
                  icon: Icons.qr_code_scanner,
                  onTap: () => onNavigate(2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          QuickActionButton(
            title: "AI Scan Fridge",
            icon: Icons.auto_awesome,
            isLarge: true,
            onTap: () => onNavigate(6),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  title: "Generate recipe",
                  icon: Icons.restaurant_menu,
                  onTap: () => onNavigate(3),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: QuickActionButton(
                  title: "Shopping list",
                  icon: Icons.list_alt,
                  onTap: () => onNavigate(4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          const SectionTitle(title: "Suggested for you"),

          const SizedBox(height: 16),

          if (suggestedRecipe == null)
            const Text(
              "No recipe suggestion available yet.",
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            )
          else
            SuggestedRecipeCard(
              title: suggestedRecipe.nom,
              subtitle: suggestedRecipe.benefices,
              badge:
                  "${suggestedRecipe.difficulte} • ${suggestedRecipe.tempsPreparation} min",
              imageUrl: suggestedRecipe.imageUrl ?? "",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecipesPage()),
                );
              },
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }
}

class HomeSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final double progress;
  final VoidCallback? onTap;

  const HomeSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF666666),
                  ),
                ),
                Icon(icon, color: const Color(0xFF2D6A4F), size: 22),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D6A4F),
              ),
            ),

            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF2D6A4F)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeAlertCard extends StatelessWidget {
  final String title;
  final String number;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color contentColor;

  const HomeAlertCard({
    super.key,
    required this.title,
    required this.number,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: contentColor, size: 24),

          const SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: contentColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: contentColor.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLarge;

  const QuickActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: isLarge ? 64 : 82,
        decoration: BoxDecoration(
          color: isLarge ? const Color(0xFF2D6A4F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isLarge)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: isLarge
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xFF666666), size: 28),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SuggestedRecipeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final String imageUrl;
  final VoidCallback onTap;

  const SuggestedRecipeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            width: double.infinity,
                            color: const Color(0xFFEEEEEE),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Color(0xFF2D6A4F),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D6A4F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "View Recipe",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: -55,
          right: 20,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9F43),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9F43).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent,
              color: Color(0xFF5A2200),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
