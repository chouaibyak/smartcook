import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartcook/providers/ingredient_provider.dart';
import 'package:smartcook/providers/recipe_provider.dart';
import 'package:smartcook/services/api_service.dart';
import 'package:smartcook/services/image_service.dart';
import '../widgets/custom_app_bar.dart';
import 'dart:async';

class AddIngredientScreen extends StatefulWidget {
  final VoidCallback? onSave;
  const AddIngredientScreen({super.key, this.onSave});

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: "0");
  final TextEditingController _expiryController = TextEditingController();
  String _selectedUnit = 'Grams (g)';
  String _selectedType = 'Vegetables';
  int _currentIndex = 1;

  final Color primaryDark = const Color(0xFF064439);
  final Color bgColor = const Color(0xFFF8F9FA);

  Timer? _debounce;
  bool _isLoadingAI = false;
  bool _isSaving = false;

   // Valeurs nutritionnelles récupérées de l'IA
  double _calories = 0, _proteins = 0, _carbs = 0, _fats = 0;

 

  @override
  void initState() {
    super.initState();

    print("INIT STATE RUNNING");

    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    Provider.of<IngredientProvider>(context, listen: false).resetNutrition();

    if (_nameController.text.isEmpty) {
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 1500), () {
      // Appelle le provider
      Provider.of<IngredientProvider>(context, listen: false)
          .fetchNutrition(_nameController.text, _selectedType);
    });
  }

  Future<void> _fetchNutritionAI(String name) async {
    setState(() => _isLoadingAI = true);
    try {
final data = await ApiService().analyzeIngredient(
  name,
  _selectedType,
);
        print(data);
      setState(() {
        _calories = (data['calories'] as num).toDouble();
        _proteins = (data['proteines'] as num).toDouble();
        _carbs = (data['glucides'] as num).toDouble();
        _fats = (data['lipides'] as num).toDouble();
      });
    } finally {
      setState(() => _isLoadingAI = false);
    }
  }


  Future<void> _handleSave() async {
    if (_isSaving) return;

    final nutri = Provider.of<IngredientProvider>(context, listen: false);
    final ingredientName = _nameController.text.trim();

    setState(() => _isSaving = true);

    try {
      if (nutri.imageUrl.isEmpty && ingredientName.isNotEmpty) {
        await nutri.fetchNutrition(ingredientName, _selectedType);
      }

      final fallbackImageUrl = ImageService.getMealDbImage(
        ingredientName,
        _selectedType,
      );
      final imageUrl = ImageService.resolveIngredientImage(
        ingredientName,
        _selectedType,
        nutri.imageUrl,
      );

      final data = {

      //  ANCIEN CODE
//"idInventaire": 1,

// NEW CODE
// supprimé car backend utilise maintenant
// req.userId depuis le JWT token


      "nom": ingredientName,
      "quantite": double.tryParse(_qtyController.text) ?? 0,
      "unite": _selectedUnit,
      "type": _selectedType,
      "dateExpiration": _expiryController.text,
      "calories": nutri.calories,
      "proteines": nutri.proteins,
      "glucides": nutri.carbs,
      "lipides": nutri.fats,
      "allergenes": nutri.allergens,
      "marque": nutri.brand,
      "categorie": nutri.category,
      "imageUrl": imageUrl.isNotEmpty ? imageUrl : fallbackImageUrl,
      };

      bool success = await ApiService().saveIngredient(data);

      if (!mounted) return;

      if (success) {
        unawaited(
          Provider.of<RecipeProvider>(
            context,
            listen: false,
          ).generateWithAi(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ingredient added successfully!"), backgroundColor: Colors.green)
        );
        if (widget.onSave != null) {
          widget.onSave!();
        }else{
          Navigator.pop(context);
        }
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error while saving"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    _qtyController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  // Fonction pour afficher le calendrier
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // On ne peut pas choisir une date passée
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryDark, // Couleur en-tête
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formate la date en mm/dd/yyyy pour le contrôleur
        _expiryController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutriProvider = Provider.of<IngredientProvider>(context);
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Title
            const Text(
              "Add New Ingredient",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 4),
            const Text(
              "Manually catalog fresh items to your digital pantry.",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 25),

            // ── FORM CARD ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Ingredient Name"),
                  _buildTextField(_nameController, "e.g. Organic Baby Spinach"),

                  _buildLabel("Quantity"),
                  _buildTextField(_qtyController, "0", isNumber: true),

                  _buildLabel("Unit"),
                  _buildDropdown(
                    ['Grams (g)', 'Kg', 'Pieces', 'Liters (L)', 'ml'],
                    _selectedUnit,
                    (v) => setState(() => _selectedUnit = v!),
                  ),

                  _buildLabel("Ingredient Type"),
                  _buildDropdown(
                   [
  'Vegetables',
  'Fruits',
  'Meat',
  'Dairy & Eggs',
  'Seafood',
  'Grains',
  'Bakery',
  'Frozen',
  'Snacks',
  'Drinks',
  'Spices',
  'Organic',
  'Canned Food',
  'Sauces',
  'Sweets',
  'Breakfast',
],
                    _selectedType,
(v) {
  setState(() => _selectedType = v!);

  if (_nameController.text.trim().isNotEmpty) {
    Provider.of<IngredientProvider>(
      context,
      listen: false,
    ).fetchNutrition(
      _nameController.text,
      _selectedType,
    );
  }
},                  ),

                  _buildLabel("Expiration Date"),
                  _buildTextField(
                    _expiryController,
                    "mm/dd/yyyy",
                    suffixIcon: Icons.calendar_today_outlined,
                    readOnly: true, // Empêche l'ouverture du clavier
                    onTap: () => _selectDate(context), // Ouvre le calendrier au clic
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ── NUTRITION CARD ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image with overlay text
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        _buildIngredientImage(),
                        // Gradient overlay
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.65),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Nutritional Information",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nutrition stats
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Estimated per 100g unit. Adjust if necessary.",
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            _buildStatCard(
                              "Calories", 
                              nutriProvider.isLoading ? "..." : nutriProvider.calories.toStringAsFixed(0),
                              "kcal"
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              "Proteins", 
                              nutriProvider.isLoading ? "..." : nutriProvider.proteins.toStringAsFixed(0),
                              "g"
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildStatCard(
                              "Carbs",
                              nutriProvider.isLoading ? "..." : nutriProvider.carbs.toStringAsFixed(1),
                              "g"
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              "Fats",
                              nutriProvider.isLoading ? "..." : nutriProvider.fats.toStringAsFixed(1),
                              "g"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── AI SUGGESTION BANNER ───────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFC1F0D8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064439).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_outlined,
                      color: Color(0xFF064439),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Suggestion",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF064439),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "SmartCook can auto-fill nutrition based on name.",
                          style: TextStyle(fontSize: 12, color: Color(0xFF064439)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── SAVE BUTTON ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: _nameController.text.isEmpty || _isSaving ? null : _handleSave,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSaving)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Text(
                        "Save Ingredient",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(width: 10),
                    Text(
                      _isSaving ? "Saving..." : "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!_isSaving)
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      );

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    IconData? suffixIcon,
    bool readOnly = false, // Ajouté
    VoidCallback? onTap,   // Ajouté
  }) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly, // Ajouté
      onTap: onTap,       // Ajouté
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 15),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.black54, size: 20)
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryDark, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildIngredientImage() {
    final name = _nameController.text.trim();
    final nutriProvider = Provider.of<IngredientProvider>(context);
    final imageUrl = ImageService.resolveIngredientImage(
      name,
      _selectedType,
      nutriProvider.imageUrl,
    );

    return Image.network(
      imageUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 180,
        width: double.infinity,
        color: const Color(0xFF2E7D32),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.white54,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
