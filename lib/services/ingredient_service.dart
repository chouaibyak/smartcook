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

  // Récupérer tous les ingrédients (Version équipe typée avec le modèle)
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

  // Version statique ou dictionnaire pour compatibilité directe avec ton écran de scan
  static Future<List<dynamic>> getInventory(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.inventory),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("GET INVENTORY ERROR: $e");
      return [];
    }
  }

  // Ajouter un aliment (Version modifiée pour envoyer TOUTES les données enrichies de ton scan)
  static Future<bool> addItem(String token, Map<String, dynamic> item) async {
    try {
      final Map<String, dynamic> backendData = {
        "nom": item['name'] ?? item['nom'],
        "quantite": item['quantity'] != null
            ? double.tryParse(item['quantity'].toString()) ?? 1.0
            : 1.0,
        "unite": item['unit'] ?? 'pcs',
        "barcode": item['barcode'],
        "dateExpiration": item['dateExpiration'],
        "type": item['type'],
        "calories": item['calories'] != null
            ? double.tryParse(item['calories'].toString())
            : null,
        "proteines": item['proteines'] != null
            ? double.tryParse(item['proteines'].toString())
            : null,
        "glucides": item['glucides'] != null
            ? double.tryParse(item['glucides'].toString())
            : null,
        "lipides": item['lipides'] != null
            ? double.tryParse(item['lipides'].toString())
            : null,
        "allergenes": item['allergenes'],
        "marque": item['brand'] ?? item['marque'],
        "categorie": item['categorie'],
        "imageUrl": item['imageUrl'],
      };

      print("DEBUG: Envoi de l'aliment complet au backend -> $backendData");

      final response = await http.post(
        Uri.parse(ApiConstants.inventory),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(backendData),
      );

      print("DEBUG: Status Code -> ${response.statusCode}");
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("ADD ITEM ERROR: $e");
      return false;
    }
  }

  // Ajouter un ingrédient via l'objet du modèle (Méthode équipe)
  Future<void> addIngredient(Ingredient ingredient) async {
    final response = await http.post(
      Uri.parse(ApiConstants.inventory),
      headers: _getHeaders(),
      body: json.encode(ingredient.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur ajout aliment: ${response.statusCode}');
    }
  }

  // Mettre à jour un ingrédient
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

  // Supprimer un ingrédient (Statique pour ton scan)
  static Future<bool> deleteItem(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.inventory}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print("DELETE ITEM ERROR: $e");
      return false;
    }
  }

  // Supprimer un ingrédient (Instance pour l'équipe)
  Future<void> deleteIngredient(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.inventory}/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression aliment: ${response.statusCode}');
    }
  }

  // Ton service indispensable de scan OpenFoodFacts
  static Future<Map<String, dynamic>> lookupBarcode(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1) {
        final product = data['product'];
        final nutriments = product['nutriments'] ?? {};

        return {
          'name': product['product_name'] ?? 'Produit inconnu',
          'quantity': '1',
          'brand': product['brands'] ?? '',
          'barcode': barcode,
          'imageUrl': product['image_front_url'] ?? product['image_url'] ?? '',
          'calories':
              nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'] ?? '',
          'proteines': nutriments['proteins_100g'] ?? '',
          'glucides': nutriments['carbohydrates_100g'] ?? '',
          'lipides': nutriments['fat_100g'] ?? '',
          'allergenes': product['allergens'] ?? '',
          'categorie': product['categories'] ?? '',
          'type':
              product['ingredients_text_fr'] ??
              product['ingredients_text'] ??
              '',
        };
      }
    }
    throw Exception('Produit non trouvé');
  }
}
