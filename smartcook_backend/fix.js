const fs = require('fs');

const inventoryController = `const db = require('../config/db');

const getInventory = async (req, res) => {
    try {
        const userId = req.user.id;
        const [inv] = await db.query('SELECT id FROM inventaire WHERE idUtilisateur = ?', [userId]);
        if (!inv.length) return res.status(404).json({ message: 'Inventaire non trouve' });
        const inventaireId = inv[0].id;
        const [rows] = await db.query('SELECT * FROM aliment WHERE idInventaire = ?', [inventaireId]);
        res.status(200).json(rows);
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

const addItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { nom, quantite, unite, barcode, marque, categorie, calories, dateExpiration } = req.body;
        if (!nom) return res.status(400).json({ message: 'Le nom est obligatoire' });
        const [inv] = await db.query('SELECT id FROM inventaire WHERE idUtilisateur = ?', [userId]);
        if (!inv.length) return res.status(404).json({ message: 'Inventaire non trouve' });
        const inventaireId = inv[0].id;
        const [result] = await db.query(
            'INSERT INTO aliment (idInventaire, nom, quantite, unite, barcode, marque, categorie, calories, dateExpiration, statut) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [inventaireId, nom, quantite || 1, unite || '', barcode || '', marque || '', categorie || '', calories || null, dateExpiration || null, 'disponible']
        );
        res.status(201).json({ message: 'Aliment ajoute', id: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

const deleteItem = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const [inv] = await db.query('SELECT id FROM inventaire WHERE idUtilisateur = ?', [userId]);
        if (!inv.length) return res.status(404).json({ message: 'Inventaire non trouve' });
        const inventaireId = inv[0].id;
        await db.query('DELETE FROM aliment WHERE id=? AND idInventaire=?', [id, inventaireId]);
        res.status(200).json({ message: 'Aliment supprime' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

module.exports = { getInventory, addItem, deleteItem };`;

fs.writeFileSync('smartcook_backend/controllers/inventoryController.js', inventoryController, { encoding: 'utf8', flag: 'w' });
console.log('Done!');