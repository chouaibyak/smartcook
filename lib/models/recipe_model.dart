class Recipe {
  final int id;
  final int idUtilisateur;
  final String nom;
  final String typeRepas;
  final int tempsPreparation;
  final String difficulte;
  final int nbPersonnes;
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
      typeRepas: json['typeRepas'] ?? '',
      tempsPreparation: json['tempsPreparation'] ?? 0,
      difficulte: json['difficulte'] ?? '',
      nbPersonnes: json['nbPersonnes'] ?? 1,
      etapes: json['etapes'] ?? '',
      calories: double.tryParse(json['calories'].toString()) ?? 0,
      proteines: double.tryParse(json['proteines'].toString()) ?? 0,
      glucides: double.tryParse(json['glucides'].toString()) ?? 0,
      lipides: double.tryParse(json['lipides'].toString()) ?? 0,
      benefices: json['benefices'] ?? '',
      conseilsSante: json['conseilsSante'] ?? '',
      scoreCompatibilite:
          double.tryParse(json['scoreCompatibilite'].toString()) ?? 0,
      imageUrl: json['imageUrl'],
    );
  }
}
