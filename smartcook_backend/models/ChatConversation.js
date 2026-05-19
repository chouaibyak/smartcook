const db = require('../config/db');

class ChatConversation {
  static async create({
    userId,
    title,
    mainSubject = 'general',
    recipeId = null,
    foodItemId = null,
    context = null,
  }) {
    const [result] = await db.query(
      `INSERT INTO chatconversation
       (idUtilisateur, titre, sujetPrincipal, recipeId, foodItemId, contexte, statut, lastMessageAt)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
      [
        userId,
        title || 'Conversation Chef AI',
        mainSubject,
        recipeId,
        foodItemId,
        context ? JSON.stringify(context) : null,
        'active',
      ]
    );

    return result.insertId;
  }

  static async belongsToUser(conversationId, userId) {
    const [rows] = await db.query(
      `SELECT id FROM chatconversation WHERE id = ? AND idUtilisateur = ?`,
      [conversationId, userId]
    );

    return rows.length > 0;
  }

  static async findAllByUser(userId) {
    const [rows] = await db.query(
      `SELECT
          c.id,
          c.titre,
          c.sujetPrincipal,
          c.recipeId,
          c.foodItemId,
          c.contexte,
          c.statut,
          c.lastMessageAt,
          (
            SELECT m.content
            FROM chatmessage m
            WHERE m.conversationId = c.id
            ORDER BY m.position DESC, m.createdAt DESC
            LIMIT 1
          ) AS lastMessage
       FROM chatconversation c
       WHERE c.idUtilisateur = ?
       ORDER BY c.lastMessageAt DESC, c.id DESC`,
      [userId]
    );

    return rows;
  }

  static async findByIdForUser(conversationId, userId) {
    const [rows] = await db.query(
      `SELECT
          id,
          titre,
          sujetPrincipal,
          recipeId,
          foodItemId,
          contexte,
          statut,
          lastMessageAt
       FROM chatconversation
       WHERE id = ? AND idUtilisateur = ?
       LIMIT 1`,
      [conversationId, userId]
    );

    return rows[0] || null;
  }

  static async touch(conversationId) {
    await db.query(
      `UPDATE chatconversation SET lastMessageAt = NOW() WHERE id = ?`,
      [conversationId]
    );
  }
}

module.exports = ChatConversation;
