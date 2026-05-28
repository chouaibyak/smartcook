import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get _host {
    if (kIsWeb) {
      return 'localhost';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
  }

  static String get baseUrl => 'http://$_host:3000/api';

  // Auth
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get completeProfile => '$baseUrl/user/complete-profile';

  // Inventory & Aliments
  static String get inventory => '$baseUrl/inventory';
  static String get aliments => '$baseUrl/aliments';

  // Recipes
  static String get recipes => '$baseUrl/recipes';

  // Shopping
  static String get shopping => '$baseUrl/shopping';

  // Chat
  static String get chat => '$baseUrl/chat';
}
