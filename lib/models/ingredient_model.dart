class Ingredient {
  final int? id;
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
    this.id,
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
    final daysUntilExpiration = dateExpiration
        .difference(DateTime.now())
        .inDays;
    return !isExpired && daysUntilExpiration <= 3;
  }

  String get statusText {
    if (isExpired) return 'Expiré';
    if (isExpiringSoon) return 'Expire bientôt';
    return 'Disponible';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.now().add(const Duration(days: 365));
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: _toInt(json['id']),
      idInventaire: json['idInventaire'] == null
          ? null
          : _toInt(json['idInventaire']),
      nom: json['nom']?.toString() ?? '',
      quantite: _toDouble(json['quantite']),
      unite: json['unite'] ?? '',
      type: json['type'] ?? '',
      dateExpiration: _parseDate(json['dateExpiration']),
      calories: json['calories'] == null ? null : _toDouble(json['calories']),
      proteines: json['proteines'] == null
          ? null
          : _toDouble(json['proteines']),
      glucides: json['glucides'] == null ? null : _toDouble(json['glucides']),
      lipides: json['lipides'] == null ? null : _toDouble(json['lipides']),
      barcode: json['barcode']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      statut: json['statut'] ?? 'disponible',
    );
  }

  Map<String, dynamic> toJson() {
  return {
    'nom': nom,
    'quantite': quantite,
    'unite': unite,
    'type': type,
    'dateExpiration': dateExpiration.toIso8601String(),
    'calories': calories,
    'proteines': proteines,
    'glucides': glucides,
    'lipides': lipides,
    'imageUrl': imageUrl,
    'statut': statut,
    'barcode': barcode,
  };
}

  // copyWith permet de créer une nouvelle instance d’Ingredient
  // en modifiant seulement qlqs les propriétés sans changer l’objet original.
  Ingredient copyWith({
    int? id,
    int? idInventaire,
    String? nom,
    double? quantite,
    String? unite,
    String? type,
    DateTime? dateExpiration,
    double? calories,
    double? proteines,
    double? glucides,
    double? lipides,
    String? imageUrl,
    String? statut,
    String? barcode,
  }) {
    return Ingredient(
      id: id ?? this.id,
      idInventaire: idInventaire ?? this.idInventaire,
      nom: nom ?? this.nom,
      quantite: quantite ?? this.quantite,
      unite: unite ?? this.unite,
      type: type ?? this.type,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      calories: calories ?? this.calories,
      proteines: proteines ?? this.proteines,
      glucides: glucides ?? this.glucides,
      lipides: lipides ?? this.lipides,
      imageUrl: imageUrl ?? this.imageUrl,
      statut: statut ?? this.statut,
      barcode: barcode ?? this.barcode,
    );
  }
}
