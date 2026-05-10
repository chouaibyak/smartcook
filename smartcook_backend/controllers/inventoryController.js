const db = require('../config/db');

const getInventory = async (req, res) => {
    try {
        const userId = req.user.id;
        const [rows] = await db.query('SELECT * FROM inventaire WHERE utilisateur_id = ?', [userId]);
        res.status(200).json(rows);
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

const addItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { nom, quantite, unite, date_expiration } = req.body;
        if (!nom) return res.status(400).json({ message: 'Le nom est obligatoire' });
        const [result] = await db.query('INSERT INTO inventaire (utilisateur_id, nom, quantite, unite, date_expiration) VALUES (?, ?, ?, ?, ?)', [userId, nom, quantite || 1, unite || '', date_expiration || null]);
        res.status(201).json({ message: 'Item ajouté', id: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

const updateItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const { nom, quantite, unite, date_expiration } = req.body;
        await db.query('UPDATE inventaire SET nom=?, quantite=?, unite=?, date_expiration=? WHERE id=? AND utilisateur_id=?', [nom, quantite, unite, date_expiration, id, userId]);
        res.status(200).json({ message: 'Item modifié' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

const deleteItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        await db.query('DELETE FROM inventaire WHERE id=? AND utilisateur_id=?', [id, userId]);
        res.status(200).json({ message: 'Item supprimé' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

module.exports = { getInventory, addItem, updateItem, deleteItem };