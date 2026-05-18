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

  // Ajouter un item à l'inventaire (Modifié pour envoyer TOUTES les données à la table `aliment`)
  static Future<bool> addItem(String token, Map<String, dynamic> item) async {
    try {
      // On prépare le dictionnaire avec TOUTES les valeurs nutritionnelles et détails
      final Map<String, dynamic> backendData = {
        "nom": item['name'] ?? item['nom'],
        "quantite": item['quantity'] != null
            ? double.tryParse(item['quantity'].toString()) ?? 1.0
            : 1.0,
        "unite": item['unit'] ?? 'pcs',
        "barcode": item['barcode'],
        "dateExpiration": item['dateExpiration'],

        // --- AJOUTS : Envoi des nouvelles données à Node.js ---
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
        "marque":
            item['brand'] ?? item['marque'], // Gère les deux alias possibles
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

  // Lookup OpenFoodFacts (Modifié pour extraire l'image, les calories, etc.)
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
          'quantity': '1', // Par défaut pour le scan initial
          'brand': product['brands'] ?? '',
          'barcode': barcode,

          // --- AJOUTS : Récupération des données depuis l'API OpenFoodFacts ---
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
