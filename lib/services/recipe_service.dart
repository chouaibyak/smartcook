import '../models/recipe_model.dart';
import '../models/ingredient_model.dart';
import 'image_service.dart';

class RecipeService {

  List<Recipe> generateSuggestedRecipes(
    List<Ingredient> ingredients,
  ) {

    final ingredientNames = ingredients
        .map((ingredient) => ingredient.nom.toLowerCase())
        .toList();

    List<Recipe> recipes = [];

    // Pasta Recipe
    if (
        ingredientNames.contains('pasta') ||
        ingredientNames.contains('tomato')
    ) {

      recipes.add(
        Recipe(
          id: 1,
          idUtilisateur: 1,
          nom: "Tomato Pasta",
          typeRepas: "Dinner",
          tempsPreparation: 20,
          difficulte: "Easy",
          nbPersonnes: 2,

          etapes:
              "Boil pasta. Prepare tomato sauce. Mix together and serve.",

          calories: 450,
          proteines: 12,
          glucides: 65,
          lipides: 10,

          benefices:
              "Rich in carbohydrates and energy for daily activities.",

          conseilsSante:
              "Use whole wheat pasta for a healthier meal.",

          scoreCompatibilite: 92,
        ),
      );
    }

    // Chicken Recipe
    if (ingredientNames.contains('chicken')) {

      recipes.add(
        Recipe(
          id: 2,
          idUtilisateur: 1,
          nom: "Chicken Salad",
          typeRepas: "Lunch",
          tempsPreparation: 15,
          difficulte: "Easy",
          nbPersonnes: 1,

          etapes:
              "Cook chicken. Mix vegetables. Add dressing and serve.",

          calories: 320,
          proteines: 28,
          glucides: 12,
          lipides: 14,

          benefices:
              "High protein meal supporting muscle recovery.",

          conseilsSante:
              "Add olive oil and fresh vegetables for better nutrition.",

          scoreCompatibilite: 88,
        ),
      );
    }

    // Default Recipe
    if (recipes.isEmpty) {

      recipes.add(
        Recipe(
          id: 0,
          idUtilisateur: 1,
          nom: "Simple Homemade Meal",
          typeRepas: "Any",
          tempsPreparation: 10,
          difficulte: "Easy",
          nbPersonnes: 1,

          etapes:
              "Use available ingredients to create a simple healthy meal.",

          calories: 250,
          proteines: 8,
          glucides: 30,
          lipides: 8,

          benefices:
              "Balanced quick meal with available ingredients.",

          conseilsSante:
              "Add more ingredients to unlock better recipe suggestions.",

          scoreCompatibilite: 50,
        ),
      );
    }

    return recipes;
  }

  String getRecipeImage(String recipeName) {
    return ImageService.getMealDbImage(recipeName);
  }
}