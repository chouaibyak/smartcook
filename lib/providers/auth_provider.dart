import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuth => _user != null;

  // LOGIN
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.login(email, password);

    _isLoading = false;

    if (result != null && result['token'] != null) {
      _user = UserModel.fromJson(result['user']);

      _user = UserModel(
        id: _user!.id,
        nom: _user!.nom,
        email: _user!.email,
        token: result['token'],
      );

      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  // REGISTER
  Future<bool> register(String nom, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await AuthService.register(nom, email, password);

    _isLoading = false;

    if (result != null && result['token'] != null) {
      _user = UserModel(
        id: result['userId'],
        nom: nom,
        email: email,
        token: result['token'],
      );

      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}