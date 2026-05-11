import 'package:flutter/material.dart';
import '../models/ingredient_model.dart';
import '../services/ingredient_service.dart';
import '../services/image_service.dart';

class IngredientProvider extends ChangeNotifier {
  final IngredientService _service = IngredientService();

  List<Ingredient> _ingredients = [];
  bool _isLoading = false;
  String? _errorMessage;

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
      return ingredient.statut.toLowerCase() == 'missing';
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
        if (ingredient.imageUrl == null || ingredient.imageUrl!.isEmpty) {
          ingredient.imageUrl = ImageService.getMealDbImage(ingredient.nom);
        }
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
      if (ingredient.imageUrl == null || ingredient.imageUrl!.isEmpty) {
        ingredient.imageUrl = ImageService.getMealDbImage(ingredient.nom);
      }

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
}