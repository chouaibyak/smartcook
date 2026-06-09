class Aliment {
  final int? id;
  final int idInventaire;
  final String nom;
  final double quantite;
  final String unite;
  final String? dateExpiration;
  final String? barcode;
  final String statut;
  final String? type;
  final double? calories;
  final double? proteines;
  final double? glucides;
  final double? lipides;
  final String? allergenes;
  final String? marque;
  final String? categorie;
  final String? imageUrl;

  Aliment({
    this.id,
    required this.idInventaire,
    required this.nom,
    required this.quantite,
    required this.unite,
    this.dateExpiration,
    this.barcode,
    this.statut = 'disponible',
    this.type,
    this.calories,
    this.proteines,
    this.glucides,
    this.lipides,
    this.allergenes,
    this.marque,
    this.categorie,
    this.imageUrl,
  });

  // 1. Convertir le JSON reçu du serveur Node.js en objet Aliment (pour l'affichage)
  factory Aliment.fromJson(Map<String, dynamic> json) {
    return Aliment(
      id: json['id'],
      idInventaire: json['idInventaire'],
      nom: json['nom'],
      quantite: (json['quantite'] as num).toDouble(),
      unite: json['unite'],
      dateExpiration: json['dateExpiration'],
      barcode: json['barcode'],
      statut: json['statut'] ?? 'disponible',
      type: json['type'],
      calories: json['calories'] != null
          ? (json['calories'] as num).toDouble()
          : null,
      proteines: json['proteines'] != null
          ? (json['proteines'] as num).toDouble()
          : null,
      glucides: json['glucides'] != null
          ? (json['glucides'] as num).toDouble()
          : null,
      lipides: json['lipides'] != null
          ? (json['lipides'] as num).toDouble()
          : null,
      allergenes: json['allergenes'],
      marque: json['marque'],
      categorie: json['categorie'],
      imageUrl: json['imageUrl'],
    );
  }

  // 2. Convertir l'objet Aliment en JSON (pour l'envoyer au serveur via addItem/updateItem)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'idInventaire': idInventaire,
      'nom': nom,
      'quantite': quantite,
      'unite': unite,
      'dateExpiration': dateExpiration,
      'barcode': barcode,
      'statut': statut,
      'type': type,
      'calories': calories,
      'proteines': proteines,
      'glucides': glucides,
      'lipides': lipides,
      'allergenes': allergenes,
      'marque': marque,
      'categorie': categorie,
      'imageUrl': imageUrl,
    };
  }
}
