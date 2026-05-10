class ApiConstants {
  // 10.0.2.2 = adresse de votre PC depuis l'émulateur Android
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Auth
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String completeProfile = '$baseUrl/user/complete-profile';

  // Inventory
  static const String inventory = '$baseUrl/inventory';

  // Recipes
  static const String recipes = '$baseUrl/recipes';

  // Shopping
  static const String shopping = '$baseUrl/shopping';

  // Chat
  static const String chat = '$baseUrl/chat';
}
