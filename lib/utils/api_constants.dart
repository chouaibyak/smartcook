import 'package:flutter/foundation.dart';

class ApiConstants {
  // localhost pour le web (Chrome) et Railway pour le mobile (téléphone)
  static const String baseUrl = kIsWeb 
      ? 'http://localhost:3000/api' 
      : 'https://smartcook-production.up.railway.app/api';
  
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String completeProfile = '$baseUrl/user/complete-profile';
}