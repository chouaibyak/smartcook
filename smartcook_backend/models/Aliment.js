const db = require('../config/db');
const Inventory = require('./Inventory');

class Aliment {
 
  
  static async create(userId, data) {
    try {
      // 1. Récupérer ou créer l'inventaire lié à l'utilisateur
      const inventory = await Inventory.getOrCreate(userId);

      const query = `INSERT INTO aliment 
        (idInventaire, nom, quantite, unite, type, dateExpiration, 
         calories, proteines, glucides, lipides, allergenes, 
         marque, categorie, imageUrl, statut) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

      const values = [
        inventory.id, // On utilise l'ID trouvé juste au-dessus
        data.nom || 'Inconnu',
        data.quantite || 1,
        data.unite || 'pcs',
        data.type || 'autre',
        data.dateExpiration || null,
        data.calories || 0,
        data.proteines || 0,
        data.glucides || 0,
        data.lipides || 0,
        data.allergenes || 'Aucun',
        data.marque || 'Générique',
        data.categorie || 'Inconnu',
        data.imageUrl || '',
        data.statut || 'disponible'
      ];

      // On utilise await (db doit être configuré avec .promise())
      const [result] = await db.query(query, values);
      
      return result.insertId; // Retourne l'ID de l'aliment créé

    } catch (error) {
      console.error('Erreur dans Aliment.create:', error.message);
      throw error;
    }
  }

  // Récupérer tous les aliments d'un utilisateur
  static async findAllByUser(userId) {
    try {
      const [rows] = await db.query(
        `SELECT a.* 
         FROM aliment a
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
        `SELECT a.* 
         FROM aliment a
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
          nom, quantite, unite, type, dateExpiration,
          calories || 0, proteines || 0, glucides || 0, lipides || 0,
          allergenes || 'Aucun', marque || 'Générique', categorie || 'Inconnu',
          barcode || null, imageUrl || '', statut || 'disponible',
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