class ApiConstants {
  // Adresse IP de ton serveur (10.0.2.2 pour l'émulateur Android)
  static const String baseUrl = 'http://localhost:3000/api';
  
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String completeProfile = '$baseUrl/user/complete-profile';
  static const String inventory = '$baseUrl/inventory';
  static const String aliments = '$baseUrl/aliments';
}
