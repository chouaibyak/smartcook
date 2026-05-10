import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class IngredientService {
  // Récupérer tous les items de l'inventaire
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

  // Ajouter un item à l'inventaire
  static Future<bool> addItem(String token, Map<String, dynamic> item) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.inventory),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(item),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("ADD ITEM ERROR: $e");
      return false;
    }
  }

  // Supprimer un item de l'inventaire
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

  // Lookup OpenFoodFacts par barcode
  static Future<Map<String, dynamic>> lookupBarcode(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 1) {
        final product = data['product'];
        return {
          'name': product['product_name'] ?? 'Produit inconnu',
          'quantity': product['quantity'] ?? '',
          'brand': product['brands'] ?? '',
        };
      }
    }
    throw Exception('Produit non trouvé');
  }
}
