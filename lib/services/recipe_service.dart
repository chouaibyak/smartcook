import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../utils/api_constants.dart';

class RecipeService {
  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Recipe>> getRecipes(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.recipes),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Recipe.fromJson(item)).toList();
    }

    throw Exception("Error loading recipes: ${response.body}");
  }

  Future<void> refreshAiRecipes(String token) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.recipes}/refresh'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "AI could not generate new recipes: ${response.body}",
      );
    }
  }

  Future<Map<String, dynamic>> prepareRecipe(String token, int recipeId) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.recipes}/$recipeId/prepare'),
      headers: _headers(token),
    );

    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode == 200) {
      return body;
    }

    throw Exception(
      body['message'] ?? body['error'] ?? 'Error while preparing the recipe',
    );
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/profile'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception("Error loading profile: ${response.body}");
  }
}
