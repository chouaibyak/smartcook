import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  static const Color primaryGreen = Color(0xFF0F5D3B);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF111111);
  static const Color textLight = Color(0xFF666666);
  static const Color orangeDark = Color(0xFFA33A00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              const Text(
                "Shopping List",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Manage your ingredients and restock essentials.",
                style: TextStyle(fontSize: 16, color: textLight),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text("Export as PDF"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: const BorderSide(color: Color(0xFFC8D5CE)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text("Add Item"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 38),

              const SectionHeader(
                icon: Icons.inventory_2_outlined,
                title: "Missing Ingredients",
                color: primaryGreen,
              ),

              const SizedBox(height: 18),

              const ShoppingSectionCard(
                children: [
                  ShoppingItemCard(
                    name: "Balsamic Vinegar",
                    subtitle: "250ml Bottle",
                    quantity: "1 unit",
                  ),
                  ShoppingItemCard(
                    name: "Fresh Rosemary",
                    subtitle: "Organic bunch",
                    quantity: "2 bunches",
                  ),
                  ShoppingItemCard(
                    name: "Heavy Cream",
                    subtitle: "Dairy Section",
                    quantity: "500ml",
                    showDivider: false,
                  ),
                ],
              ),

              const SizedBox(height: 42),

              const SectionHeader(
                icon: Icons.error_outline,
                title: "Expired / Low Stock",
                color: orangeDark,
              ),

              const SizedBox(height: 18),

              const ShoppingSectionCard(
                children: [
                  ShoppingItemCard(
                    name: "Whole Milk",
                    subtitle: "Expired yesterday",
                    quantity: "1 Gallon",
                    isWarning: true,
                  ),
                  ShoppingItemCard(
                    name: "Baby Spinach",
                    subtitle: "Low stock: 10% left",
                    quantity: "1 Large Bag",
                    isWarning: true,
                  ),
                  ShoppingItemCard(
                    name: "Greek Yogurt",
                    subtitle: "Expires today",
                    quantity: "2 Cups",
                    isWarning: true,
                    showDivider: false,
                  ),
                ],
              ),

              const SizedBox(height: 42),

              const SuggestionCard(),

              const SizedBox(height: 90),
            ],
          ),
        ),
      );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 26),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class ShoppingSectionCard extends StatelessWidget {
  final List<Widget> children;

  const ShoppingSectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class ShoppingItemCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String quantity;
  final bool isWarning;
  final bool showDivider;

  const ShoppingItemCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.quantity,
    this.isWarning = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final quantityBg = isWarning
        ? const Color(0xFFFFF3EE)
        : const Color(0xFFE9FFF3);

    final quantityColor = isWarning
        ? const Color(0xFFA33A00)
        : const Color(0xFF0F5D3B);

    final subtitleColor = isWarning ? const Color(0xFFD00000) : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: Color(0xFFEDEDED), width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFB8C5BD), width: 1.5),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: quantityBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              quantity,
              style: TextStyle(
                fontSize: 16,
                color: quantityColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            image: const DecorationImage(
              image: NetworkImage(
                "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?q=80&w=1200",
              ),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: const Color(0xFF0F5D3B).withOpacity(0.55),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Missing ingredients for\nTonight's Ratatouille?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "SmartCook added 4 items to your\nlist.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1.0,
                  ),
                ),

                const Spacer(),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF0F5D3B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Review Suggestions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),

       
      ],
    );
  }
}
