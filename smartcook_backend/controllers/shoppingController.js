const db = require('../config/db');
const getShoppingList = async (req, res) => {
    try {
        const userId = req.user.id;
        const [rows] = await db.query('SELECT * FROM listecourses WHERE utilisateur_id = ?', [userId]);
        res.status(200).json(rows);
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};
const addItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { nom, quantite } = req.body;
        if (!nom) return res.status(400).json({ message: 'Le nom est obligatoire' });
        const [result] = await db.query('INSERT INTO listecourses (utilisateur_id, nom, quantite) VALUES (?, ?, ?)', [userId, nom, quantite || 1]);
        res.status(201).json({ message: 'Item ajoute', id: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};
const deleteItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        await db.query('DELETE FROM listecourses WHERE id=? AND utilisateur_id=?', [id, userId]);
        res.status(200).json({ message: 'Item supprime' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};
module.exports = { getShoppingList, addItem, deleteItem };