const db = require('../config/db');

class Inventory {

  static async findByUserId(userId) {
    try {
      const cleanId = parseInt(typeof userId === 'object' ? userId.id : userId);
      const [rows] = await db.query(
        'SELECT id FROM inventaire WHERE idUtilisateur = ?',
        [cleanId]
      );

      return rows[0] || null;

    } catch (error) {
      console.error("Inventory findByUserId error:", error);
      throw error;
    }
  }

  static async create(userId) {
    try {
      const cleanId = parseInt(typeof userId === 'object' ? userId.id : userId);
      const [result] = await db.query(
        'INSERT INTO inventaire (idUtilisateur) VALUES (?)',
        [cleanId]
      );

      return result.insertId;

    } catch (error) {
      console.error("Inventory create error:", error);
      throw error;
    }
  }

  static async getOrCreate(userId) {
    try {
      const cleanId = parseInt(userId);
      if (isNaN(cleanId)) throw new Error("Invalid user ID");
      let inventory = await this.findByUserId(cleanId);

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
