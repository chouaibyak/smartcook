import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ingredient_model.dart';
import '../providers/ingredient_provider.dart';
import '../services/pdf_service.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final Set<int> checkedItems = {};

  static const Color primaryGreen = Color(0xFF0F5D3B);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF111111);
  static const Color textLight = Color(0xFF666666);
  static const Color orangeDark = Color(0xFFA33A00);

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  void showMarkAsAvailableForm(Ingredient ingredient) {
    final provider = Provider.of<IngredientProvider>(context, listen: false);
    final isMissingItem = ingredient.statut.toLowerCase() == "missing";

    final quantityController = TextEditingController(
      text: ingredient.quantite > 0 ? _formatQuantity(ingredient.quantite) : "",
    );
    final typeController = TextEditingController(
      text: ingredient.type.toLowerCase() == "shopping"
          ? "Ingredient"
          : ingredient.type,
    );
    final allowedUnits = [
      "pcs",
      "piece",
      "g",
      "kg",
      "ml",
      "L",
      "pack",
      "boite",
      "gousse",
    ];

    String selectedUnit = allowedUnits.contains(ingredient.unite)
        ? ingredient.unite
        : "pcs";
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Confirm purchase",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    ingredient.nom,
                    style: const TextStyle(fontSize: 16, color: textLight),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Quantity purchased",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: const InputDecoration(
                      labelText: "Unit",
                      border: OutlineInputBorder(),
                    ),
                    items: allowedUnits
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedUnit = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(
                      labelText: "Inventory category",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  OutlinedButton.icon(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );

                      if (pickedDate != null) {
                        setModalState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      "Expiration: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final quantity = double.tryParse(
                          quantityController.text.trim(),
                        );

                        if (quantity == null || quantity <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a valid quantity"),
                            ),
                          );
                          return;
                        }

                        final inventoryQuantity = isMissingItem
                            ? quantity
                            : ingredient.quantite + quantity;
                        final inventoryType = typeController.text.trim();

                        if (inventoryType.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a category"),
                            ),
                          );
                          return;
                        }

                        final updatedIngredient = ingredient.copyWith(
                          quantite: inventoryQuantity,
                          unite: selectedUnit,
                          dateExpiration: selectedDate,
                          type: inventoryType,
                          statut: "disponible",
                        );

                        final success = await provider.updateIngredient(
                          ingredient.id!,
                          updatedIngredient,
                        );

                        if (success) {
                          await provider.fetchIngredients();

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${ingredient.nom} added to inventory",
                                ),
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.errorMessage ?? "Update failed",
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Confirm and add to inventory"),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> replaceExpiredItem(Ingredient ingredient) async {
    final provider = Provider.of<IngredientProvider>(context, listen: false);

    // 1. supprimer l'ancien aliment expiré
    await provider.deleteIngredient(ingredient.id!);

    // 2. créer un nouvel item shopping
    final replacementIngredient = Ingredient(
      nom: ingredient.nom,
      quantite: ingredient.quantite,
      unite: ingredient.unite,
      type: ingredient.type,
      dateExpiration: DateTime.now().add(const Duration(days: 7)),
      statut: "missing",
    );

    // 3. ajouter à la shopping list
    await provider.addIngredient(replacementIngredient);

    // 4. refresh
    await provider.fetchIngredients();
  }

  Future<void> removeExpiredItem(Ingredient ingredient) async {
    await Provider.of<IngredientProvider>(
      context,
      listen: false,
    ).deleteIngredient(ingredient.id!);

    await Provider.of<IngredientProvider>(
      context,
      listen: false,
    ).fetchIngredients();
  }

  @override
  Widget build(BuildContext context) {
    final ingredientProvider = Provider.of<IngredientProvider>(context);
    final ingredients = ingredientProvider.ingredients;
    bool isLowStock(Ingredient ingredient) {
      final unit = ingredient.unite.toLowerCase();
      final quantity = ingredient.quantite;

      if (unit == "g") return quantity <= 200;
      if (unit == "kg") return quantity <= 0.25;

      if (unit == "ml") return quantity <= 250;
      if (unit == "l") return quantity <= 0.25;

      if (unit == "pcs" || unit == "pc") return quantity <= 1;
      if (unit == "pack" || unit == "box") return quantity <= 1;

      return false;
    }

    final missingIngredients = ingredients.where((ingredient) {
      return ingredient.statut.toLowerCase() == 'missing' ||
          ingredient.quantite <= 0;
    }).toList();

    final lowStockIngredients = ingredients.where((ingredient) {
      return !ingredient.isExpired &&
          ingredient.statut.toLowerCase() != "missing" &&
          ingredient.quantite > 0 &&
          isLowStock(ingredient);
    }).toList();

    final expiredIngredients = ingredients.where((ingredient) {
      return ingredient.isExpired;
    }).toList();

    void _showAddShoppingItemForm() {
      final nameController = TextEditingController();
      final quantityController = TextEditingController();
      String selectedUnit = "pcs";

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Shopping Item",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Item name",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Quantity",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: "Unit",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "pcs", child: Text("pcs")),
                        DropdownMenuItem(value: "g", child: Text("g")),
                        DropdownMenuItem(value: "kg", child: Text("kg")),
                        DropdownMenuItem(value: "ml", child: Text("ml")),
                        DropdownMenuItem(value: "L", child: Text("L")),
                        DropdownMenuItem(value: "pack", child: Text("pack")),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          selectedUnit = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final quantityText = quantityController.text.trim();

                          if (name.isEmpty || quantityText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill all fields"),
                              ),
                            );
                            return;
                          }

                          final newIngredient = Ingredient(
                            nom: name,
                            quantite: double.tryParse(quantityText) ?? 1,
                            unite: selectedUnit,
                            type: "Shopping",
                            dateExpiration: DateTime.now().add(
                              const Duration(days: 7),
                            ),
                            statut: "missing",
                          );

                          final provider = Provider.of<IngredientProvider>(
                            context,
                            listen: false,
                          );

                          final success = await provider.addIngredient(
                            newIngredient,
                          );

                          if (success) {
                            await provider.fetchIngredients();

                            if (context.mounted) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Item added to shopping list"),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    provider.errorMessage ??
                                        "Failed to add item",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5D3B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Add to Shopping List"),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
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
                    onPressed: () {
                      PdfService.exportShoppingList(
                        missingIngredients: missingIngredients,
                      );
                    },
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
                    onPressed: _showAddShoppingItemForm,
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

            ShoppingSectionCard(
              children: missingIngredients.isEmpty
                  ? [
                      const EmptyShoppingMessage(
                        message: "No missing ingredients",
                      ),
                    ]
                  : missingIngredients.map((ingredient) {
                      return ShoppingItemCard(
                        name: ingredient.nom,
                        subtitle: ingredient.type ?? "Ingredient",
                        quantity: "Missing",
                        isChecked: checkedItems.contains(ingredient.id),
                        onToggle: () async {
                          showMarkAsAvailableForm(ingredient);
                        },
                      );
                    }).toList(),
            ),

            const SizedBox(height: 42),

            const SectionHeader(
              icon: Icons.error_outline,
              title: "Low stock ",
              color: orangeDark,
            ),

            const SizedBox(height: 18),

            ShoppingSectionCard(
              children: expiredIngredients.isEmpty
                  ? [const EmptyShoppingMessage(message: "No low stock items")]
                  : lowStockIngredients.map((ingredient) {
                      return ShoppingItemCard(
                        name: ingredient.nom,
                        subtitle: "Low stock",
                        quantity: "${ingredient.quantite} ${ingredient.unite}",
                        isWarning: true,
                        isChecked: checkedItems.contains(ingredient.id),
                        onToggle: () async {
                          showMarkAsAvailableForm(ingredient);
                        },
                      );
                    }).toList(),
            ),

            const SizedBox(height: 42),

            const SectionHeader(
              icon: Icons.error_outline,
              title: "Expired ",
              color: orangeDark,
            ),

            const SizedBox(height: 18),

            ShoppingSectionCard(
              children: expiredIngredients.isEmpty
                  ? [const EmptyShoppingMessage(message: "No expired items")]
                  : expiredIngredients.map((ingredient) {
                      return ShoppingItemCard(
                        name: ingredient.nom,
                        subtitle: "Expired",
                        quantity: "${ingredient.quantite} ${ingredient.unite}",
                        isWarning: true,
                        isChecked: false,
                        onToggle: () {},
                        showActions: true,
                        onRemove: () => removeExpiredItem(ingredient),
                        onReplace: () => replaceExpiredItem(ingredient),
                      );
                    }).toList(),
            ),

            const SizedBox(height: 42),


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
  final bool isChecked;
  final VoidCallback onToggle;
  final bool isWarning;
  final bool showDivider;
  final bool showActions;
  final VoidCallback? onRemove;
  final VoidCallback? onReplace;

  const ShoppingItemCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.quantity,
    required this.isChecked,
    required this.onToggle,
    this.isWarning = false,
    this.showDivider = true,
    this.showActions = false,
    this.onRemove,
    this.onReplace,
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
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? const Color(0xFF0F5D3B)
                        : Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFFB8C5BD),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isChecked ? Colors.grey : Colors.black,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : null,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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

          if (showActions)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 12),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: onRemove,
                    child: const Text("Remove"),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: onReplace,
                    child: const Text("Replace"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


class EmptyShoppingMessage extends StatelessWidget {
  final String message;

  const EmptyShoppingMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Text(
        message,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }
}
