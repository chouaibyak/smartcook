import 'dart:convert';

class RecipeIngredient {
  final String nom;
  final double quantite;
  final String unite;

  const RecipeIngredient({
    required this.nom,
    required this.quantite,
    required this.unite,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      nom: json['nom']?.toString() ?? '',
      quantite: double.tryParse(json['quantite'].toString()) ?? 0,
      unite: json['unite']?.toString() ?? '',
    );
  }
}

class Recipe {
  final int id;
  final int idUtilisateur;
  final String nom;
  final String typeRepas;
  final int tempsPreparation;
  final String difficulte;
  final int nbPersonnes;
  final List<RecipeIngredient> ingredientsDisponibles;
  final List<RecipeIngredient> ingredientsManquants;
  final String etapes;
  final double calories;
  final double proteines;
  final double glucides;
  final double lipides;
  final String benefices;
  final String conseilsSante;
  final double scoreCompatibilite;
  final String? imageUrl;

  Recipe({
    required this.id,
    required this.idUtilisateur,
    required this.nom,
    required this.typeRepas,
    required this.tempsPreparation,
    required this.difficulte,
    required this.nbPersonnes,
    this.ingredientsDisponibles = const [],
    this.ingredientsManquants = const [],
    required this.etapes,
    required this.calories,
    required this.proteines,
    required this.glucides,
    required this.lipides,
    required this.benefices,
    required this.conseilsSante,
    required this.scoreCompatibilite,
    this.imageUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      idUtilisateur: json['idUtilisateur'],
      nom: json['nom'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/600',
      typeRepas: json['typeRepas'] ?? '',
      tempsPreparation: json['tempsPreparation'] ?? 0,
      difficulte: json['difficulte'] ?? '',
      nbPersonnes: json['nbPersonnes'] ?? 1,
      ingredientsDisponibles: _parseIngredients(json['ingredientsDisponibles']),
      ingredientsManquants: _parseIngredients(json['ingredientsManquants']),
      etapes: json['etapes'] ?? '',
      calories: double.tryParse(json['calories'].toString()) ?? 0,
      proteines: double.tryParse(json['proteines'].toString()) ?? 0,
      glucides: double.tryParse(json['glucides'].toString()) ?? 0,
      lipides: double.tryParse(json['lipides'].toString()) ?? 0,
      benefices: json['benefices'] ?? '',
      conseilsSante: json['conseilsSante'] ?? '',
      scoreCompatibilite:
          double.tryParse(json['scoreCompatibilite'].toString()) ?? 0,
    );
  }

  static List<RecipeIngredient> _parseIngredients(dynamic value) {
    if (value == null) return [];

    dynamic decoded = value;
    if (value is String) {
      if (value.trim().isEmpty) return [];
      try {
        decoded = jsonDecode(value);
      } catch (_) {
        return [];
      }
    }

    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((item) => RecipeIngredient.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ))
        .where((ingredient) => ingredient.nom.trim().isNotEmpty)
        .toList();
  }
}
