import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/ingredient_provider.dart';
import '../models/ingredient_model.dart';
import 'add_ingredient_screen.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String _searchQuery = '';
  String _selectedFilter = "All Items";

 final List<String> _filters = [
  "All Items",
  "Vegetables",
  "Dairy & Eggs",
  "Meat",
  "Fruits",
  "Seafood",
  "Bakery",
  "Frozen",
  "Snacks",
  "Drinks",
  "Organic",
];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIngredients();
    });
  }

  Future<void> _loadIngredients() async {
    final provider = Provider.of<IngredientProvider>(
      context,
      listen: false,
    );

    await provider.fetchIngredients();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IngredientProvider>(context);
    final grouped = _groupByCategory(provider.ingredients);

   return Material(
  color: Colors.grey[50],
  child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

        
             /// SEARCH BAR
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Container(
    height: 58,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),

    child: TextField(
      decoration: InputDecoration(
        hintText: "Search inventory or ask 'What can I cook?'",

        hintStyle: TextStyle(
          color: Colors.grey[500],
          fontSize: 15,
        ),

        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF155E3B),
        ),

        suffixIcon: Container(
          margin: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: const Color(0xFFE8F5EE),
            borderRadius: BorderRadius.circular(12),
          ),

          child: const Icon(
            Icons.auto_awesome,
            color: Color(0xFF155E3B),
            size: 20,
          ),
        ),

        border: InputBorder.none,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
        ),
      ),

      onChanged: (val) {
        setState(() {
          _searchQuery = val;
        });
      },
    ),
  ),
),

const SizedBox(height: 18),


/// FILTERS
Column(
  children: [
    SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF155E3B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF155E3B)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),

    const SizedBox(height: 8),

    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(
            Icons.arrow_left,
            size: 18,
            color: Colors.grey.shade500,
          ),

          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 131, 128, 128),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          Icon(
            Icons.arrow_right,
            size: 18,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    ),
  ],
),

const SizedBox(height: 16),


           

            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : grouped.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: grouped.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            
                                ...entry.value.map(
                                  (item) => _buildCard(item),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildCard(Ingredient ingredient) {
  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
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

        /// IMAGE + STATUS
        Stack(
          children: [

            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),

              child: ingredient.imageUrl != null &&
                      ingredient.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ingredient.imageUrl!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 40,
                      ),
                    ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: _buildStatusChip(ingredient),
            ),
          ],
        ),

        /// CONTENT
        Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// LEFT
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    ingredient.nom,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Quantity: ${ingredient.quantite} ${ingredient.unite}",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              /// RIGHT
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),

                    onPressed: () {
                      _confirmDelete(ingredient);
                    },

                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color.fromARGB(255, 179, 82, 75),
                      size: 24,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    ingredient.isExpired
                        ? "${ingredient.dateExpiration.day}/${ingredient.dateExpiration.month}/${ingredient.dateExpiration.year}"
                        : _formatExpirationDate(
                            ingredient.dateExpiration,
                          ),

                    style: TextStyle(
                      color: ingredient.isExpired
                          ? const Color.fromARGB(255, 202, 89, 81)
                          : ingredient.isExpiringSoon
                              ? Colors.orange
                              : const Color(0xFF155E3B),

                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


void _confirmDelete(Ingredient ingredient) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
title: const Text("Delete Ingredient"),
content: Text("Do you want to delete ${ingredient.nom}?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);

            await Provider.of<IngredientProvider>(
              context,
              listen: false,
            ).deleteIngredient(ingredient.id!);

            _loadIngredients();
          },
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
Widget _buildStatusChip(Ingredient ingredient) {
  String text;
  Color bg;
  Color textColor;
  IconData icon;

  if (ingredient.isExpired) {
    text = "Expired";
    bg = const Color(0xFFFFD6D6);
    textColor = const Color(0xFFC62828);
    icon = Icons.error_outline;
  } else if (ingredient.isExpiringSoon) {
    text = "Expiring soon";
    bg = const Color(0xFFFFB366);
    textColor = const Color(0xFF7A3500);
    icon = Icons.warning_amber_rounded;
  } else {
    text = "Available";
    bg = const Color(0xFFB9F6CA);
    textColor = const Color(0xFF065F46);
    icon = Icons.check_circle_outline;
  }

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),

    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),

    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Icon(
          icon,
          size: 14,
          color: textColor,
        ),

        const SizedBox(width: 4),

        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}
  Map<String, List<Ingredient>> _groupByCategory(
    List<Ingredient> ingredients,
  ) {
    final Map<String, List<Ingredient>> grouped = {};

    List<Ingredient> filtered = ingredients;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((i) {
        return i.nom.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    if (_selectedFilter != "All Items") {
      filtered = filtered.where((i) {
        return (i.type ?? '').toLowerCase().contains(
              _selectedFilter.toLowerCase(),
            );
      }).toList();
    }

    for (var item in filtered) {
      final category = (item.type ?? 'Other').isEmpty ? 'Other' : item.type!;

      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(item);
    }

    return grouped;
  }

  String _formatExpirationDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiration = DateTime(date.year, date.month, date.day);

    final diff = expiration.difference(today).inDays;

    if (diff < 0) return "Expired";
    if (diff == 0) return "Today";
    if (diff == 1) return "Tomorrow";
    if (diff <= 7) return "In $diff days";

    return "${date.day}/${date.month}/${date.year}";
  }

  void _navigateToAddIngredient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddIngredientScreen(),
      ),
    ).then((_) => _loadIngredients());
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No ingredients found",
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}