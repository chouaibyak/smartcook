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
      if (_token != null)
        "Authorization": "Bearer $_token",
    };
  }

  Future<Map<String, dynamic>> analyzeIngredient(String name) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.aliments}/analyze?name=$name'),
      headers: _headers(),
    );

    print("ANALYZE STATUS: ${response.statusCode}");
    print("ANALYZE BODY: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return {
      "calories": 0,
      "proteines": 0,
      "glucides": 0,
      "lipides": 0
    };
  }

  Future<bool> saveIngredient(Map<String, dynamic> data) async {
    print("HEADERS: ${_headers()}");

    final response = await http.post(
      Uri.parse(ApiConstants.inventory),
      headers: _headers(),
      body: json.encode(data),
    );

    print("SAVE STATUS: ${response.statusCode}");
    print("SAVE BODY: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
