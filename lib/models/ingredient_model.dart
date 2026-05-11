class Ingredient {
  final int id;
  final int? idInventaire;
  final String nom;
  final double quantite;
  final String unite;
  final String type;
  final DateTime dateExpiration;
  final double? calories;
  final double? proteines;
  final double? glucides;
  final double? lipides;
  final String? barcode;
  String? imageUrl;  
  final String statut;

  Ingredient({
    required this.id,
    this.idInventaire,
    required this.nom,
    required this.quantite,
    required this.unite,
    required this.type,
    required this.dateExpiration,
    this.calories,
    this.proteines,
    this.glucides,
    this.lipides,
    this.barcode,
    this.imageUrl,  
    this.statut = 'disponible',
  });

  bool get isExpired => dateExpiration.isBefore(DateTime.now());
  
  bool get isExpiringSoon {
    final daysUntilExpiration = dateExpiration.difference(DateTime.now()).inDays;
    return !isExpired && daysUntilExpiration <= 3;
  }

  String get statusText {
    if (isExpired) return 'Expiré';
    if (isExpiringSoon) return 'Expire bientôt';
    return 'Disponible';
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      idInventaire: json['idInventaire'],
      nom: json['nom'],
      quantite: json['quantite']?.toDouble() ?? 0,
      unite: json['unite'] ?? '',
      type: json['type'] ?? '',
      dateExpiration: DateTime.parse(json['dateExpiration']),
      calories: json['calories']?.toDouble(),
      proteines: json['proteines']?.toDouble(),
      glucides: json['glucides']?.toDouble(),
      lipides: json['lipides']?.toDouble(),
      barcode: json['barcode'],
      imageUrl: json['imageUrl'],
      statut: json['statut'] ?? 'disponible',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'quantite': quantite,
      'unite': unite,
      'type': type,
      'dateExpiration': dateExpiration.toIso8601String().split('T')[0],
      'calories': calories,
      'proteines': proteines,
      'glucides': glucides,
      'lipides': lipides,
      'barcode': barcode,
      'imageUrl': imageUrl,
    };
  }
}