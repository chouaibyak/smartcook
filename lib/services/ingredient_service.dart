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
          // Correction ici : un seul espace après Bearer pour éviter le bug 401
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

  // Ajouter un item à l'inventaire (Ajoute une ligne dans la table `aliment`)
  static Future<bool> addItem(String token, Map<String, dynamic> item) async {
    try {
      // On adapte les clés pour correspondre EXACTEMENT aux colonnes de ta table `aliment`
      final Map<String, dynamic> backendData = {
        "nom": item['name'] ?? item['nom'],
        "quantite": item['quantity'] != null
            ? double.tryParse(item['quantity'].toString()) ?? 1.0
            : 1.0, // Double comme dans ton SQL
        "unite": item['unit'] ?? 'pcs',
        "barcode": item['barcode'], // <-- AJOUT DE LA COLONNE BARCODE ICI
        "dateExpiration":
            item['dateExpiration'], // Correspond à ton fichier SQL
      };

      print("DEBUG: Envoi de l'aliment au backend -> $backendData");

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

  // Lookup OpenFoodFacts par barcode (Fidèle à ton interface ServiceOpenFoodFacts du diagramme)
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
          'barcode':
              barcode, // On garde le barcode en mémoire pour l'ajouter plus tard !
        };
      }
    }
    throw Exception('Produit non trouvé');
  }
}
