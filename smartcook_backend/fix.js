const fs = require('fs');

const recipeController = `const db = require('../config/db');
const getRecipes = async (req, res) => {
    try {
        const userId = req.user.id;
        const [rows] = await db.query('SELECT * FROM recette WHERE utilisateur_id = ?', [userId]);
        res.status(200).json(rows);
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};
const addRecipe = async (req, res) => {
    try {
        const userId = req.user.id;
        const { titre, description, ingredients, instructions } = req.body;
        if (!titre) return res.status(400).json({ message: 'Le titre est obligatoire' });
        const [result] = await db.query('INSERT INTO recette (utilisateur_id, titre, description, ingredients, instructions) VALUES (?, ?, ?, ?, ?)', [userId, titre, description || '', ingredients || '', instructions || '']);
        res.status(201).json({ message: 'Recette ajoutee', id: result.insertId });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};
const deleteRecipe = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        await db.query('DELETE FROM recette WHERE id=? AND utilisateur_id=?', [id, userId]);
        res.status(200).json({ message: 'Recette supprimee' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};
module.exports = { getRecipes, addRecipe, deleteRecipe };`;

const shoppingController = `const db = require('../config/db');
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
module.exports = { getShoppingList, addItem, deleteItem };`;

const chatController = `const db = require('../config/db');
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
module.exports = { getMessages, sendMessage };`;

fs.writeFileSync('controllers/recipeController.js', recipeController, { encoding: 'utf8', flag: 'w' });
fs.writeFileSync('controllers/shoppingController.js', shoppingController, { encoding: 'utf8', flag: 'w' });
fs.writeFileSync('controllers/chatController.js', chatController, { encoding: 'utf8', flag: 'w' });
console.log('Done!');