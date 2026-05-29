import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class ApiService {
  // SINGLETON
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
    print("TOKEN SAVED: $_token");
  }

  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (_token != null) "Authorization": "Bearer $_token",
    };
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<Map<String, dynamic>> analyzeIngredient(
    String name,
    String type,
  ) async {
    final uri = Uri.parse('${ApiConstants.aliments}/analyze').replace(
      queryParameters: {
        'name': name,
        'type': type,
      },
    );

    final response = await http.get(
      uri,
      headers: _headers(),
    );

    print("ANALYZE STATUS: ${response.statusCode}");
    print("ANALYZE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return {
        "calories": _toDouble(data["calories"]),
        "proteines": _toDouble(data["proteines"]),
        "glucides": _toDouble(data["glucides"]),
        "lipides": _toDouble(data["lipides"]),
        "allergenes": data["allergenes"]?.toString() ?? "Non renseigné",
        "categorie": data["categorie"]?.toString() ?? type,
        "marque": data["marque"]?.toString() ?? "Inconnu",
        "imageUrl": data["imageUrl"]?.toString() ?? "",
      };
    }

    return {
      "calories": 0,
      "proteines": 0,
      "glucides": 0,
      "lipides": 0,
      "allergenes": "Non renseigné",
      "categorie": type,
      "marque": "Inconnu",
      "imageUrl": "",
    };
  }

  Future<bool> saveIngredient(Map<String, dynamic> data) async {
    print("HEADERS: ${_headers()}");

    final response = await http.post(
      Uri.parse('${ApiConstants.aliments}/add'),
      headers: _headers(),
      body: json.encode(data),
    );

    print("SAVE STATUS: ${response.statusCode}");
    print("SAVE BODY: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
