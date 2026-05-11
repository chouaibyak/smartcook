const db = require('../config/db');

class Inventory {

  static async findByUserId(userId) {
    try {
      const [rows] = await db.query(
        'SELECT id FROM inventaire WHERE idUtilisateur = ?',
        [userId]
      );

      return rows[0] || null;

    } catch (error) {
      console.error("Inventory findByUserId error:", error);
      throw error;
    }
  }

  static async create(userId) {
    try {
      const [result] = await db.query(
        'INSERT INTO inventaire (idUtilisateur) VALUES (?)',
        [userId]
      );

      return result.insertId;

    } catch (error) {
      console.error("Inventory create error:", error);
      throw error;
    }
  }

  static async getOrCreate(userId) {
    try {
      let inventory = await this.findByUserId(userId);

      if (!inventory) {
        const id = await this.create(userId);
        inventory = { id };
      }

      return inventory;

    } catch (error) {
      console.error("Inventory getOrCreate error:", error);
      throw error;
    }
  }
}

module.exports = Inventory;