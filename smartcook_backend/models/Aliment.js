const db = require('../config/db');
const Inventory = require('./Inventory');

const toQuantity = (value, fallback = 0) => {
  const number = Number(value);
  return Number.isFinite(number) ? number : fallback;
};

const statusForQuantity = (quantity, status) => {
  if (toQuantity(quantity) <= 0) return 'missing';
  return status || 'disponible';
};

class Aliment {

  static async create(userId, data) {
    try {
      // 1. Récupérer ou créer l'inventaire lié à l'utilisateur
      const inventory = await Inventory.getOrCreate(userId);

      //  CORRIGÉ : Ajout de la colonne barcode dans le INSERT
      const query = `INSERT INTO aliment 
        (idInventaire, nom, quantite, unite, type, dateExpiration, barcode,
         calories, proteines, glucides, lipides, allergenes, 
         marque, categorie, imageUrl, statut) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
      const quantity = toQuantity(data.quantite, 1);

      const values = [
        inventory.id, // On utilise l'ID trouvé juste au-dessus
        data.nom || 'Unknown',
        quantity,
        data.unite || 'pcs',
        data.type || 'autre',
        data.dateExpiration || null,
        data.barcode || null, // ✅ Ajouté ici
        data.calories || 0,
        data.proteines || 0,
        data.glucides || 0,
        data.lipides || 0,
        data.allergenes || 'Not provided',
        data.marque || 'Generic',
        data.categorie || 'Unknown',
        data.imageUrl || '',
        statusForQuantity(quantity, data.statut)
      ];

      console.log("Insertion aliment :", values);
      const [result] = await db.query(query, values);
      return result.insertId; 

    } catch (error) {
      console.error('Erreur dans Aliment.create:', error.message);
      throw error;
    }
  }

  // Récupérer tous les aliments d'un utilisateur
  static async findAllByUser(userId) {
    try {
      const [rows] = await db.query(
        `SELECT a.* FROM aliment a
         JOIN inventaire i ON a.idInventaire = i.id
         WHERE i.idUtilisateur = ?
         ORDER BY a.dateExpiration ASC`,
        [userId]
      );
      return rows || [];
    } catch (error) {
      console.error('Erreur findAllByUser:', error);
      return [];
    }
  }

  // Récupérer un aliment par ID
  static async findById(id, userId) {
    try {
      const [rows] = await db.query(
        `SELECT a.* FROM aliment a
         JOIN inventaire i ON a.idInventaire = i.id
         WHERE a.id = ? AND i.idUtilisateur = ?`,
        [id, userId]
      );
      return rows[0] || null;
    } catch (error) {
      console.error('Erreur findById:', error);
      return null;
    }
  }

  // Modifier un aliment
  static async update(id, userId, data) {
    try {
      const {
        nom, quantite, unite, type, dateExpiration,
        calories, proteines, glucides, lipides,
        allergenes, marque, categorie, barcode, imageUrl, statut
      } = data;

      const formattedDate = dateExpiration
        ? dateExpiration.split('T')[0]
        : null;

      const [result] = await db.query(
        `UPDATE aliment a
         JOIN inventaire i ON a.idInventaire = i.id
         SET
           a.nom = ?, a.quantite = ?, a.unite = ?, a.type = ?,
           a.dateExpiration = ?, a.calories = ?, a.proteines = ?,
           a.glucides = ?, a.lipides = ?, a.allergenes = ?,
           a.marque = ?, a.categorie = ?, a.barcode = ?,
           a.imageUrl = ?, a.statut = ?
         WHERE a.id = ? AND i.idUtilisateur = ?`,
        [
          nom, quantite, unite, type, formattedDate,
          calories || 0, proteines || 0, glucides || 0, lipides || 0,
          allergenes || 'None', marque || 'Generic', categorie || 'Unknown',
          barcode || null, imageUrl || '', statusForQuantity(quantite, statut),
          id, userId
        ]
      );
      return result.affectedRows > 0;
    } catch (error) {
      console.error('Erreur update:', error);
      return false;
    }
  }

  // Supprimer un aliment
  static async delete(id, userId) {
    try {
      const [result] = await db.query(
        `DELETE a FROM aliment a
         JOIN inventaire i ON a.idInventaire = i.id
         WHERE a.id = ? AND i.idUtilisateur = ?`,
        [id, userId]
      );
      return result.affectedRows > 0;
    } catch (error) {
      console.error('Erreur delete:', error);
      return false;
    }
  }

  // Vérifier appartenance utilisateur
  static async belongsToUser(id, userId) {
    try {
      const [rows] = await db.query(
        `SELECT a.id FROM aliment a
         JOIN inventaire i ON a.idInventaire = i.id
         WHERE a.id = ? AND i.idUtilisateur = ?`,
         [id, userId]
      );
      return rows.length > 0;
    } catch (error) {
      console.error('Erreur belongsToUser:', error);
      return false;
    }
  }
}

module.exports = Aliment;
