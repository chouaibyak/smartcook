import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/ingredient_model.dart';
import '../services/ingredient_service.dart';
import '../services/image_service.dart';

class IngredientProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  final IngredientService _service = IngredientService();

  List<Ingredient> _ingredients = [];
  bool _isLoading = false;
  String? _errorMessage;


  double calories = 0, proteins = 0, carbs = 0, fats = 0;
  String category = "", allergens = "", brand = "", imageUrl = "";

  void resetNutrition() {
    calories = 0;
    proteins = 0;
    carbs = 0;
    fats = 0;
    category = "";
    allergens = "";
    brand = "";
    imageUrl = "";
    notifyListeners();
  }

  void clearData() {
  _ingredients = [];
  _isLoading = false;
  _errorMessage = null;

  calories = 0;
  proteins = 0;
  carbs = 0;
  fats = 0;

  category = "";
  allergens = "";
  brand = "";
  imageUrl = "";

  notifyListeners();
}

Future<void> fetchNutrition(String name, String type) async {    _isLoading = true;
    notifyListeners();

    try {
final data = await _apiService.analyzeIngredient(name, type);
      calories = (data['calories'] as num).toDouble();
      proteins = (data['proteines'] as num).toDouble();
      carbs = (data['glucides'] as num).toDouble();
      fats = (data['lipides'] as num).toDouble();

      // Récupération des infos IA
      category = data['categorie'] ?? "Unknown";
      allergens = data['allergenes'] ?? "Aucun";
      brand = data['marque'] ?? "Generic";
      imageUrl = data['imageUrl'] ?? "";
      
    } catch (e) {
      print("Erreur Provider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Ingredient> get ingredients => _ingredients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // -------- Getters pour HomeScreen --------

  int get totalItems => _ingredients.length;

  int get expiringSoonCount {
    final today = DateTime.now();

    return _ingredients.where((ingredient) {
      final date = ingredient.dateExpiration;

      if (date == null) return false;

      final difference = date.difference(today).inDays;

      return difference >= 0 && difference <= 2;
    }).length;
  }

  double get inventoryProgress {
    if (_ingredients.isEmpty) return 0.0;

    const maxItems = 100;
    final progress = _ingredients.length / maxItems;

    return progress > 1 ? 1.0 : progress;
  }

  int get missingCount {
    return _ingredients.where((ingredient) {
      return ingredient.statut.toLowerCase() == 'missing' ||
          ingredient.quantite <= 0;
    }).length;
  }

  // -------- CRUD --------

Future<void> fetchIngredients() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    _ingredients = await _service.getAllIngredients();

    for (var ingredient in _ingredients) {
      ingredient.imageUrl = ImageService.resolveIngredientImage(
        ingredient.nom,
        ingredient.type,
        ingredient.imageUrl,
      );
    }
  } catch (e) {
    _errorMessage = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<bool> addIngredient(Ingredient ingredient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      ingredient.imageUrl = ImageService.resolveIngredientImage(
        ingredient.nom,
        ingredient.type,
        ingredient.imageUrl,
      );

      await _service.addIngredient(ingredient);
      await fetchIngredients();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateIngredient(int id, Ingredient ingredient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateIngredient(id, ingredient);
      await fetchIngredients();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteIngredient(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteIngredient(id);
      await fetchIngredients();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, List<Ingredient>> getIngredientsByCategory() {
    Map<String, List<Ingredient>> grouped = {};

    for (var ingredient in _ingredients) {
      final category = ingredient.type;

      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }

      grouped[category]!.add(ingredient);
    }

    return grouped;
  }


  void setToken(String token) {
  _service.setToken(token);
  _apiService.setToken(token);
}
}
