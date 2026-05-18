import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingredient_model.dart';
import '../utils/api_constants.dart';

class IngredientService {
  static final IngredientService _instance = IngredientService._internal();
  factory IngredientService() => _instance;
  IngredientService._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> _getHeaders() {
    if (_token == null || _token!.isEmpty) {
      throw Exception('Token manquant. Veuillez vous reconnecter.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  Future<List<Ingredient>> getAllIngredients() async {
    final response = await http.get(
      Uri.parse(ApiConstants.inventory),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ingredient.fromJson(json)).toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    }

    throw Exception('Erreur chargement inventaire: ${response.statusCode}');
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    final response = await http.post(
      Uri.parse(ApiConstants.inventory),
      headers: _getHeaders(),
      body: json.encode(ingredient.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur ajout aliment: ${response.statusCode}');
    }
  }

  Future<void> updateIngredient(int id, Ingredient ingredient) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.inventory}/$id'),
      headers: _getHeaders(),
      body: json.encode(ingredient.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur mise à jour aliment: ${response.statusCode}');
    }
  }

  Future<void> deleteIngredient(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.inventory}/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression aliment: ${response.statusCode}');
    }
  }
}
