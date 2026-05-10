const db = require('../config/db');
const getMessages = async (req, res) => {
    try {
        const userId = req.user.id;
        const [rows] = await db.query('SELECT * FROM messagechat WHERE utilisateur_id = ? ORDER BY created_at ASC', [userId]);
        res.status(200).json(rows);
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};
const sendMessage = async (req, res) => {
    try {
        const userId = req.user.id;
        const { message } = req.body;
        if (!message) return res.status(400).json({ message: 'Le message est obligatoire' });
        const [result] = await db.query('INSERT INTO messagechat (utilisateur_id, message, expediteur) VALUES (?, ?, ?)', [userId, message, 'user']);
        res.status(201).json({ message: 'Message envoye', id: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};
module.exports = { getMessages, sendMessage };