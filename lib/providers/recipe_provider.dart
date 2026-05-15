import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _recipes = [];
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  List<Recipe> get recipes => _recipes;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Recipe? get firstSuggestedRecipe => _recipes.isNotEmpty ? _recipes.first : null;

  void setToken(String token) {
    _token = token;
  }

  Future<void> loadData([String? token]) async {
    final activeToken = token ?? _token;
    if (activeToken == null || activeToken.isEmpty) {
      _errorMessage = "Token manquant. Veuillez vous reconnecter.";
      notifyListeners();
      return;
    }

    _token = activeToken;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _recipeService.getRecipes(activeToken),
        _recipeService.getProfile(activeToken),
      ]);

      _recipes = results[0] as List<Recipe>;
      _profile = results[1] as Map<String, dynamic>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecipes([String? token]) async {
    final activeToken = token ?? _token;
    if (activeToken == null || activeToken.isEmpty) return;

    _token = activeToken;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await _recipeService.getRecipes(activeToken);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateWithAi([String? token]) async {
    final activeToken = token ?? _token;
    if (activeToken == null || activeToken.isEmpty) {
      _errorMessage = "Token manquant. Veuillez vous reconnecter.";
      notifyListeners();
      return;
    }

    _token = activeToken;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _recipeService.refreshAiRecipes(activeToken);
      _recipes = await _recipeService.getRecipes(activeToken);
      _profile = await _recipeService.getProfile(activeToken);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
