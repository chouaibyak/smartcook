import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';
import '../services/recipe_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeService _service = RecipeService();

  List<Recipe> _suggestedRecipes = [];
  bool _isLoading = false;

  List<Recipe> get suggestedRecipes => _suggestedRecipes;
  bool get isLoading => _isLoading;

  Recipe? get firstSuggestedRecipe {
    if (_suggestedRecipes.isEmpty) return null;
    return _suggestedRecipes.first;
  }

  void generateSuggestions(List<Ingredient> ingredients) {
    _isLoading = true;
    notifyListeners();

    _suggestedRecipes = _service.generateSuggestedRecipes(ingredients);

    _isLoading = false;
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestedRecipes.clear();
    notifyListeners();
  }

  String getRecipeImage(String recipeName) {
  return _service.getRecipeImage(recipeName);
}
}