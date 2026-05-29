import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcook/screens/recipe_detail_screen.dart';

import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class RecipesPage extends StatefulWidget {
  final String? token;
  final ValueChanged<int>? onNavigate;

  const RecipesPage({super.key, this.token, this.onNavigate});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  int _selectedCategory = 0;
  int _servings = 2;
  String _searchQuery = '';

  final List<String> _categories = ['All Meals', 'Breakfast', 'Lunch', 'Dinner'];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      if (widget.token != null && widget.token!.isNotEmpty) {
        provider.setToken(widget.token!);
      }
      provider.loadData(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);
    final recipes = _filteredRecipes(provider.recipes);

    return RefreshIndicator(
      onRefresh: () => provider.loadData(widget.token),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildTopControls(provider),
            const SizedBox(height: 16),
            _buildProfileCard(provider.profile),
            const SizedBox(height: 16),
            _buildCategoryTabs(),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null)
              _buildMessageCard(provider.errorMessage!)
            else if (recipes.isEmpty)
              _buildMessageCard(
                "No recipes available. Add at least 2 ingredients, then generate a new list.",
              )
            else
              ...recipes.map(
                (recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRecipeCard(recipe),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Recipe> _filteredRecipes(List<Recipe> recipes) {
    return recipes.where((recipe) {
      final matchesSearch = _searchQuery.isEmpty ||
          recipe.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.typeRepas.toLowerCase().contains(_searchQuery.toLowerCase());

      final selected = _categories[_selectedCategory].toLowerCase();
      final matchesCategory = selected == 'all meals' ||
          _mealCategoryOf(recipe.typeRepas) == selected;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  String _mealCategoryOf(String typeRepas) {
    final value = typeRepas
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i');

    if (value.contains('breakfast') ||
        value.contains('dejeuner') ||
        value.contains('petit dejeuner') ||
        value.contains('petit-dejeuner')) {
      return 'breakfast';
    }

    if (value.contains('lunch')) {
      return 'lunch';
    }

    if (value.contains('dinner') || value.contains('diner')) {
      return 'dinner';
    }

    return value;
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'What are you craving?',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          prefixIcon: const Icon(
            Icons.auto_awesome,
            size: 18,
            color: Color(0xFF2D6A4F),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }

  Widget _buildTopControls(RecipeProvider provider) {
    return Row(
      children: [
        _buildServingsSelector(),
        const Spacer(),
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading
                ? null
                : () => provider.generateWithAi(widget.token),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Generate"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6A4F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServingsSelector() {
    return Container(
      height: 40,
      width: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              if (_servings > 1) setState(() => _servings--);
            },
            child: const Icon(Icons.remove, size: 16, color: Color(0xFF666666)),
          ),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: Color(0xFF666666)),
              const SizedBox(width: 4),
              Text(
                '$_servings',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() => _servings++),
            child: const Icon(Icons.add, size: 16, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic>? profile) {
    final goal = profile?['objectifNutritionnel']?.toString();
    final allergies = _formatProfileValue(profile?['allergies']);
    final diet = _formatProfileValue(profile?['preferencesAlimentaires']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFF2D6A4F), size: 18),
              SizedBox(width: 8),
              Text(
                "Health profile",
                style: TextStyle(
                  color: Color(0xFF2D6A4F),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Goal: ${goal == null || goal.isEmpty ? 'Not defined' : goal}",
            style: const TextStyle(fontSize: 13, color: Color(0xFF345247)),
          ),
          const SizedBox(height: 4),
          Text(
            "Allergies: ${allergies.isEmpty ? 'None' : allergies}",
            style: const TextStyle(fontSize: 13, color: Color(0xFF345247)),
          ),
          const SizedBox(height: 4),
          Text(
            "Diet: ${diet.isEmpty ? 'None' : diet}",
            style: const TextStyle(fontSize: 13, color: Color(0xFF345247)),
          ),
        ],
      ),
    );
  }

  String _formatProfileValue(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.join(', ');

    final text = value.toString();
    if (text.isEmpty) return '';

    try {
      final decoded = jsonDecode(text);
      if (decoded is List) return decoded.join(', ');
    } catch (_) {
      return text;
    }

    return text;
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (index) {
          final bool isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2D6A4F) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2D6A4F)
                      : Colors.grey.shade200,
                ),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF555555),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              recipe: recipe,
              onNavigate: widget.onNavigate,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Image.network(
                    recipe.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A4F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: Colors.white, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          '${recipe.scoreCompatibilite.toStringAsFixed(0)}% AI Match',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.nom,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.access_time_outlined,
                        '${recipe.tempsPreparation} min',
                      ),
                      _buildInfoChip(
                        Icons.local_fire_department_outlined,
                        '${recipe.calories.toStringAsFixed(0)} kcal',
                      ),
                      _buildInfoChip(Icons.bar_chart, recipe.difficulte),
                      _buildInfoChip(Icons.restaurant, recipe.typeRepas),
                    ],
                  ),
                  if (recipe.benefices.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      recipe.benefices,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (recipe.conseilsSante.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      recipe.conseilsSante,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2D6A4F),
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF888888)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
