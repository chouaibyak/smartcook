import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';

class RecipeService {
  final String baseUrl = "http://localhost:3000/api";

  Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Recipe>> getRecipes(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipes'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Recipe.fromJson(item)).toList();
    }

    throw Exception("Erreur lors du chargement des recettes: ${response.body}");
  }

  Future<void> refreshAiRecipes(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recipes/refresh'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "L'IA n'a pas pu generer de nouvelles recettes: ${response.body}",
      );
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: _headers(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception("Erreur lors du chargement du profil: ${response.body}");
  }
}
