import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuth => _user != null;
  String? get token => _user?.token;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.login(email, password);

    _isLoading = false;

    if (result != null && result['token'] != null) {
      final token = result['token'];
      final user = UserModel.fromJson(result['user']);

      _user = UserModel(
        id: user.id,
        nom: user.nom,
        email: user.email,
        token: token,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<bool> register(String nom, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.register(nom, email, password);

    _isLoading = false;

    if (result != null && result['token'] != null) {
      final token = result['token'];

      _user = UserModel(
        id: result['userId'] ?? result['user']?['id'],
        nom: nom,
        email: email,
        token: token,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');

    if (savedToken != null) {
      _user = UserModel(
        id: 0,
        nom: '',
        email: '',
        token: savedToken,
      );
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    notifyListeners();
  }
}
