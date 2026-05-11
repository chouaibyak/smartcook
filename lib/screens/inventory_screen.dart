import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/ingredient_model.dart';
import '../providers/ingredient_provider.dart';
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

    return Container(
      color: Colors.grey[50],
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search inventory...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Chip(
                        label: Text(filter),
                        backgroundColor: isSelected
                            ? const Color(0xFF155E3B)
                            : Colors.grey[200],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

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
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
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

        /// IMAGE
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
                     height: 130,
width: double.infinity,
fit: BoxFit.cover,
alignment: Alignment.center,

                      placeholder: (context, url) => Container(
                        height: 120,
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),

                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                        ),
                      ),
                    )
                  : Container(
                      height: 120,
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// LEFT SIDE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    ingredient.nom,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Quantity: ${ingredient.quantite} ${ingredient.unite}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

Text(
  ingredient.isExpired
      ? "${ingredient.dateExpiration.day}/${ingredient.dateExpiration.month}/${ingredient.dateExpiration.year}"
      : _formatExpirationDate(ingredient.dateExpiration),

  style: TextStyle(
    color: ingredient.isExpired
        ? Colors.red
        : ingredient.isExpiringSoon
            ? Colors.orange
            : const Color(0xFF155E3B),

    fontWeight: FontWeight.w600,
    fontSize: 15,
  ),
),
            ],
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

    if (ingredient.isExpired) {
      text = "Expired";
      bg = Colors.red.shade100;
      textColor = Colors.red;
    } else if (ingredient.isExpiringSoon) {
      text = "Expiring soon";
      bg = Colors.orange.shade100;
      textColor = Colors.orange.shade900;
    } else {
      text = "Available";
      bg = Colors.green.shade100;
      textColor = const Color(0xFF155E3B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
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