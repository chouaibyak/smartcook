const db = require('../config/db');
const Inventory = require('./Inventory');

class Aliment {
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
      // ✅ Toujours retourner un tableau, même vide
      return rows || [];
    } catch (error) {
      console.error('Erreur findAllByUser:', error);
      return []; // Retourner tableau vide en cas d'erreur
    }
  }

  // Récupérer un aliment par son ID
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

  // Ajouter un aliment
  static async create(userId, data) {
    try {
      // Récupérer ou créer l'inventaire
      const inventory = await Inventory.getOrCreate(userId);
      
      const {
        nom,
        quantite,
        unite,
        type,
        dateExpiration,
        calories,
        proteines,
        glucides,
        lipides,
        barcode,
        imageUrl
      } = data;

      const [result] = await db.query(
        `INSERT INTO aliment 
         (idInventaire, nom, quantite, unite, type, dateExpiration, 
          calories, proteines, glucides, lipides, barcode, imageUrl, statut)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [inventory.id, nom, quantite, unite, type, dateExpiration,
         calories || null, proteines || null, glucides || null, lipides || null, 
         barcode || null, imageUrl || null, 'disponible']
      );

      return result.insertId;
    } catch (error) {
      console.error('Erreur create:', error);
      throw error;
    }
  }

  // Mettre à jour un aliment
  static async update(id, userId, data) {
    try {
      const {
        nom,
        quantite,
        unite,
        type,
        dateExpiration,
        calories,
        proteines,
        glucides,
        lipides
      } = data;

      const [result] = await db.query(
        `UPDATE aliment a
         JOIN inventaire i ON a.idInventaire = i.id
         SET a.nom = ?, a.quantite = ?, a.unite = ?, a.type = ?,
             a.dateExpiration = ?, a.calories = ?, a.proteines = ?,
             a.glucides = ?, a.lipides = ?
         WHERE a.id = ? AND i.idUtilisateur = ?`,
        [nom, quantite, unite, type, dateExpiration,
         calories || null, proteines || null, glucides || null, lipides || null, 
         id, userId]
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

  // Vérifier si l'aliment appartient à l'utilisateur
  static async belongsToUser(id, userId) {
    try {
      const [rows] = await db.query(
        `SELECT a.id 
         FROM aliment a
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