// lib/models/user_model.dart
class UserModel {
  final int id;
  final String email;
  final String nom;
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    required this.nom,
    this.token
    });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nom: json['nom'],
      token: json['token']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'token': token,
    };
  }

}