const db = require('../config/db');

class ChatMessage {
  static async getNextPosition(conversationId) {
    const [rows] = await db.query(
      `SELECT COALESCE(MAX(position), 0) + 1 AS nextPosition
       FROM chatmessage
       WHERE conversationId = ?`,
      [conversationId]
    );

    return rows[0]?.nextPosition || 1;
  }

  static async create({
    conversationId,
    role,
    content,
    messageType = 'text',
    payload = null,
    recipeId = null,
    foodItemId = null,
    position,
  }) {
    const finalPosition =
      position || (await ChatMessage.getNextPosition(conversationId));

    const [result] = await db.query(
      `INSERT INTO chatmessage
       (conversationId, role, content, messageType, payload, recipeId, foodItemId, position, createdAt)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
      [
        conversationId,
        role,
        content,
        messageType,
        payload ? JSON.stringify(payload) : null,
        recipeId,
        foodItemId,
        finalPosition,
      ]
    );

    return result.insertId;
  }

  static async findAllByConversation(conversationId) {
    const [rows] = await db.query(
      `SELECT
          id,
          conversationId,
          role,
          content,
          messageType,
          payload,
          recipeId,
          foodItemId,
          position,
          createdAt
       FROM chatmessage
       WHERE conversationId = ?
       ORDER BY position ASC, createdAt ASC`,
      [conversationId]
    );

    return rows;
  }
}

module.exports = ChatMessage;
