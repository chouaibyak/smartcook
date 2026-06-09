import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcook/models/ingredient_model.dart';
import 'package:smartcook/models/recipe_model.dart';
import 'package:smartcook/providers/auth_provider.dart';
import 'package:smartcook/providers/ingredient_provider.dart';
import 'package:smartcook/providers/recipe_provider.dart';
import 'package:smartcook/screens/chatbot_screen.dart';
import 'package:smartcook/widgets/custom_app_bar.dart';
import 'package:smartcook/widgets/custom_bottom_nav_bar.dart';

const _kPrimary = Color(0xFF1F6F4A);
const _kDeepGreen = Color(0xFF0D5A3C);
const _kMint = Color(0xFFDDF8E9);
const _kSoftMint = Color(0xFFECFBF3);
const _kOrange = Color(0xFFE8522A);
const _kBg = Color(0xFFF7F7F4);
const _kTextDark = Color(0xFF1F2924);
const _kTextMuted = Color(0xFF66736D);

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  final ValueChanged<int>? onNavigate;

  const RecipeDetailScreen({super.key, required this.recipe, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final ingredients = context.watch<IngredientProvider>().ingredients;
    final steps = _parseSteps(recipe.etapes);
    final pantry = recipe.ingredientsDisponibles
        .map(_IngredientLine.fromRecipe)
        .toList();
    final missing = recipe.ingredientsManquants
        .map(_IngredientLine.fromRecipe)
        .toList();
    final readyPercent = _readyPercent(pantry.length, missing.length);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: CustomAppBar(
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: _kPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: _kPrimary),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, color: _kPrimary),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroHeader(recipe: recipe),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Column(
                children: [
                  _NutritionCard(recipe: recipe),
                  const SizedBox(height: 18),
                  _IngredientsCard(
                    pantry: pantry,
                    missing: missing,
                    readyPercent: readyPercent,
                  ),
                  const SizedBox(height: 18),
                  _PrepareRecipeButton(recipe: recipe),
                  const SizedBox(height: 18),
                  _StepsCard(steps: steps),
                  const SizedBox(height: 18),
                  const _SubstitutionCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        onTap: (index) => _handleBottomNavTap(context, index),
      ),
    );
  }

  List<_IngredientLine> _pantryIngredients(List<Ingredient> ingredients) {
    final used = _ingredientsUsedInRecipe(ingredients)
        .where((i) => i.statut.toLowerCase() == 'disponible' && i.quantite > 0)
        .map(_IngredientLine.fromInventory)
        .toList();

    if (used.isNotEmpty) return used;

    return ingredients
        .where((i) => i.statut.toLowerCase() == 'disponible' && i.quantite > 0)
        .map(_IngredientLine.fromInventory)
        .take(5)
        .toList();
  }

  List<_IngredientLine> _missingIngredients(List<Ingredient> ingredients) {
    final usedMissing = _ingredientsUsedInRecipe(ingredients)
        .where((i) => i.statut.toLowerCase() != 'disponible' || i.quantite <= 0)
        .map(_IngredientLine.fromInventory)
        .toList();

    if (usedMissing.isNotEmpty) return usedMissing;

    return ingredients
        .where((i) => i.statut.toLowerCase() != 'disponible' || i.quantite <= 0)
        .map(_IngredientLine.fromInventory)
        .take(3)
        .toList();
  }

  List<Ingredient> _ingredientsUsedInRecipe(List<Ingredient> ingredients) {
    final source = '${recipe.nom} ${recipe.etapes} ${recipe.benefices}'
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');

    return ingredients.where((ingredient) {
      final name = ingredient.nom.toLowerCase().trim();
      return name.length > 1 && source.contains(name);
    }).toList();
  }

  int _readyPercent(int pantryCount, int missingCount) {
    final total = pantryCount + missingCount;
    if (total == 0) return 0;
    return ((pantryCount / total) * 100).round();
  }

  void _handleBottomNavTap(BuildContext context, int index) {
    final navigate = onNavigate;
    if (navigate != null) {
      navigate(index);
      Navigator.maybePop(context);
      return;
    }

    Navigator.maybePop(context);
  }
}

class _HeroHeader extends StatelessWidget {
  final Recipe recipe;

  const _HeroHeader({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 306,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            recipe.imageUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFE5E5E0),
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 54,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x55000000),
                  Color(0xD0000000),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 54,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TagRow(recipe: recipe),
                const SizedBox(height: 8),
                Text(
                  recipe.nom,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                if (recipe.benefices.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    recipe.benefices,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  final Recipe recipe;

  const _TagRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final tags = [
      if (recipe.typeRepas.isNotEmpty) recipe.typeRepas,
      '${recipe.tempsPreparation} Mins',
      if (recipe.difficulte.isNotEmpty) recipe.difficulte,
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) => _Tag(label: tag)).toList(),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _kMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _kDeepGreen,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final Recipe recipe;

  const _NutritionCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Summary',
            style: TextStyle(
              color: _kTextDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.85,
            children: [
              _NutritionCell(
                value: recipe.calories.toStringAsFixed(0),
                label: 'Calories',
              ),
              _NutritionCell(
                value: '${recipe.proteines.toStringAsFixed(0)}g',
                label: 'Protein',
                accent: _kOrange,
              ),
              _NutritionCell(
                value: '${recipe.glucides.toStringAsFixed(0)}g',
                label: 'Carbs',
              ),
              _NutritionCell(
                value: '${recipe.lipides.toStringAsFixed(0)}g',
                label: 'Fat',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutritionCell extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;

  const _NutritionCell({
    required this.value,
    required this.label,
    this.accent = _kTextDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: _kTextMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _IngredientsCard extends StatelessWidget {
  final List<_IngredientLine> pantry;
  final List<_IngredientLine> missing;
  final int readyPercent;

  const _IngredientsCard({
    required this.pantry,
    required this.missing,
    required this.readyPercent,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ingredients',
                  style: TextStyle(
                    color: _kTextDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$readyPercent% Ready',
                style: const TextStyle(
                  color: _kDeepGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (pantry.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionLabel('IN PANTRY'),
            const SizedBox(height: 8),
            ...pantry.map(
              (ingredient) =>
                  _IngredientRow(ingredient: ingredient, available: true),
            ),
          ],
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 14),
            const _SectionLabel('MISSING', color: _kOrange),
            const SizedBox(height: 8),
            ...missing.map(
              (ingredient) =>
                  _IngredientRow(ingredient: ingredient, available: false),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Missing ingredients added to your list.'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA73D00),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.shopping_cart_outlined, size: 17),
                label: const Text(
                  'Add missing to list',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
          if (pantry.isEmpty && missing.isEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'No ingredient data found for this recipe yet.',
              style: TextStyle(color: _kTextMuted, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionLabel(this.label, {this.color = _kTextMuted});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final _IngredientLine ingredient;
  final bool available;

  const _IngredientRow({required this.ingredient, required this.available});

  @override
  Widget build(BuildContext context) {
    final amount = ingredient.label;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: available ? _kSoftMint : const Color(0xFFFFFAF5),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: available ? Colors.transparent : const Color(0xFFFFD9BD),
        ),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle_outline : Icons.add_circle_outline,
            color: available ? _kDeepGreen : _kOrange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _kTextDark,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!available)
            const Text(
              'Missing',
              style: TextStyle(color: _kTextMuted, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _PrepareRecipeButton extends StatefulWidget {
  final Recipe recipe;

  const _PrepareRecipeButton({required this.recipe});

  @override
  State<_PrepareRecipeButton> createState() => _PrepareRecipeButtonState();
}

class _PrepareRecipeButtonState extends State<_PrepareRecipeButton> {
  bool _isPreparing = false;

  Future<void> _prepareRecipe() async {
    if (_isPreparing) return;

    setState(() => _isPreparing = true);

    final recipeProvider = context.read<RecipeProvider>();
    final ingredientProvider = context.read<IngredientProvider>();

    final result = await recipeProvider.prepareRecipe(widget.recipe.id);
    await ingredientProvider.fetchIngredients();

    if (!mounted) return;

    setState(() => _isPreparing = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            recipeProvider.errorMessage ??
                "Unable to prepare this recipe right now.",
          ),
          backgroundColor: _kOrange,
        ),
      );
      return;
    }

    final consumedCount = (result['consumed'] as List?)?.length ?? 0;
    final missingCount = (result['missing'] as List?)?.length ?? 0;
    final message = missingCount > 0
        ? "Recipe prepared: $consumedCount ingredient(s) updated, $missingCount added to the list."
        : "Recipe prepared: $consumedCount ingredient(s) deducted from inventory.";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _kDeepGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isPreparing ? null : _prepareRecipe,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _kPrimary.withOpacity(0.45),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: _isPreparing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.local_dining_outlined, size: 18),
          label: Text(
            _isPreparing ? 'Prepare' : 'Prepare this recipe',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _IngredientLine {
  final String nom;
  final double quantite;
  final String unite;

  const _IngredientLine({
    required this.nom,
    required this.quantite,
    required this.unite,
  });

  factory _IngredientLine.fromInventory(Ingredient ingredient) {
    return _IngredientLine(
      nom: ingredient.nom,
      quantite: ingredient.quantite,
      unite: ingredient.unite,
    );
  }

  factory _IngredientLine.fromRecipe(RecipeIngredient ingredient) {
    return _IngredientLine(
      nom: ingredient.nom,
      quantite: ingredient.quantite,
      unite: ingredient.unite,
    );
  }

  String get label {
    final quantity = _formatQuantity(quantite);
    return [
      if (quantity != '0') quantity,
      if (unite.trim().isNotEmpty) unite.trim(),
      nom,
    ].join(' ');
  }

  static String _formatQuantity(double value) {
    if (value == 0) return '0';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

class _StepsCard extends StatelessWidget {
  final List<_RecipeStep> steps;

  const _StepsCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step-by-Step Instructions',
            style: TextStyle(
              color: _kTextDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (steps.isEmpty)
            const Text(
              'No instructions available yet.',
              style: TextStyle(color: _kTextMuted, fontSize: 13),
            )
          else
            ...List.generate(
              steps.length,
              (index) => _StepItem(
                number: index + 1,
                step: steps[index],
                isLast: index == steps.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final _RecipeStep step;
  final bool isLast;

  const _StepItem({
    required this.number,
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFB8F1D0),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: _kDeepGreen,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    color: _kTextDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (step.description.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    step.description,
                    style: const TextStyle(
                      color: _kTextMuted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
                if (step.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _StepImages(urls: step.imageUrls),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepImages extends StatelessWidget {
  final List<String> urls;

  const _StepImages({required this.urls});

  @override
  Widget build(BuildContext context) {
    final visibleUrls = urls.take(2).toList();
    return Row(
      children: visibleUrls
          .map(
            (url) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: url == visibleUrls.last ? 0 : 10,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    url,
                    height: 92,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 92,
                      color: const Color(0xFFEDEDEA),
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SubstitutionCard extends StatelessWidget {
  const _SubstitutionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: _kDeepGreen,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Need a substitution?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ask the AI Sous-Chef how to swap\ningredients or adjust for dietary needs.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatbotScreen(
                    token: context.read<AuthProvider>().token,
                    selectedBottomNavIndex: 3,
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDFF7EA),
              foregroundColor: _kDeepGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ask Chatbot'),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RecipeStep {
  final String title;
  final String description;
  final List<String> imageUrls;

  const _RecipeStep({
    required this.title,
    required this.description,
    this.imageUrls = const [],
  });
}

List<_RecipeStep> _parseSteps(String rawSteps) {
  final raw = rawSteps.trim();
  if (raw.isEmpty) return [];

  try {
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .map((item) {
            if (item is String) {
              return _RecipeStep(title: 'Step', description: item.trim());
            }
            if (item is Map<String, dynamic>) {
              return _RecipeStep(
                title: _firstNotEmpty([
                  item['titre'],
                  item['title'],
                  item['nom'],
                  item['name'],
                ], fallback: 'Step'),
                description: _firstNotEmpty([
                  item['description'],
                  item['instructions'],
                  item['detail'],
                  item['text'],
                ]),
                imageUrls: _extractImageUrls(item),
              );
            }
            return null;
          })
          .whereType<_RecipeStep>()
          .toList();
    }
  } catch (_) {}

  return _parsePlainTextSteps(raw);
}

List<_RecipeStep> _parsePlainTextSteps(String raw) {
  final normalized = raw.replaceAll(RegExp(r'\r\n?'), '\n').trim();
  final matches = RegExp(
    r'(?:^|\s)(\d+)[\).:-]\s+',
    multiLine: true,
  ).allMatches(normalized).toList();

  if (matches.isNotEmpty) {
    return List.generate(matches.length, (index) {
          final match = matches[index];
          final nextStart = index + 1 < matches.length
              ? matches[index + 1].start
              : normalized.length;
          final content = normalized.substring(match.end, nextStart).trim();
          return _stepFromText(content, fallbackTitle: 'Step ${index + 1}');
        })
        .where((step) => step.description.isNotEmpty || step.title.isNotEmpty)
        .toList();
  }

  final chunks = normalized
      .split(RegExp(r'\n{1,}|;\s+'))
      .map((chunk) => chunk.trim())
      .where((chunk) => chunk.isNotEmpty)
      .toList();

  if (chunks.length > 1) {
    return List.generate(
      chunks.length,
      (index) =>
          _stepFromText(chunks[index], fallbackTitle: 'Step ${index + 1}'),
    );
  }

  return [_RecipeStep(title: 'Instructions', description: normalized)];
}

_RecipeStep _stepFromText(String text, {required String fallbackTitle}) {
  final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (cleaned.isEmpty) {
    return _RecipeStep(title: fallbackTitle, description: '');
  }

  final colonIndex = cleaned.indexOf(':');
  if (colonIndex > 0 && colonIndex < 48) {
    return _RecipeStep(
      title: cleaned.substring(0, colonIndex).trim(),
      description: cleaned.substring(colonIndex + 1).trim(),
    );
  }

  final firstSentence = RegExp(
    r'^(.{12,70}?[.!?])\s+(.+)$',
  ).firstMatch(cleaned);
  if (firstSentence != null) {
    return _RecipeStep(
      title: firstSentence.group(1)!.replaceAll(RegExp(r'[.!?]$'), ''),
      description: firstSentence.group(2)!.trim(),
    );
  }

  return _RecipeStep(title: fallbackTitle, description: cleaned);
}

String _firstNotEmpty(List<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

List<String> _extractImageUrls(Map<String, dynamic> item) {
  final urls = <String>[];
  for (final key in ['imageUrl', 'image', 'images', 'imageUrls']) {
    final value = item[key];
    if (value is String && value.trim().isNotEmpty) {
      urls.add(value.trim());
    } else if (value is List) {
      urls.addAll(
        value
            .map((entry) => entry?.toString().trim() ?? '')
            .where((entry) => entry.isNotEmpty),
      );
    }
  }
  return urls;
}
