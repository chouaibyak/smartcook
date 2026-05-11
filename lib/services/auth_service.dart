import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';

class AuthService {
  // Inscription
  static Future<Map<String, dynamic>?> register(String nom, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nom': nom, 'email': email, 'password': password}),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("REGISTER ERROR: $e");
      return {'error': e.toString()};
    }
  }

  // Connexion
// Connexion
static Future<Map<String, dynamic>?> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");
    
    final data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      return data; // Retourne { token, user, message }
    } else {
      return {'message': data['message'] ?? 'Login failed'};
    }
  } catch (e) {
    print("LOGIN ERROR: $e");
    return {'message': 'Network error'};
  }
}

  // Mise à jour du profil (Route protégée)
  static Future<bool> completeProfile(String token, Map<String, dynamic> profileData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.completeProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // On envoie le token reçu au register/login
        },
        body: jsonEncode(profileData),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}