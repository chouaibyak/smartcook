const db = require('../config/db');

const getRecipes = async (req, res) => {
    try {
        const userId = req.user.id;
        const [rows] = await db.query(
            'SELECT * FROM recette WHERE utilisateur_id = ?',
            [userId]
        );
        res.status(200).json(rows);
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

const addRecipe = async (req, res) => {
    try {
        const userId = req.user.id;
        const { titre, description, ingredients, instructions } = req.body;

        if (!titre) {
            return res.status(400).json({ message: 'Le titre est obligatoire' });
        }

        const [result] = await db.query(
            'INSERT INTO recette (utilisateur_id, titre, description, ingredients, instructions) VALUES (?, ?, ?, ?, ?)',
            [userId, titre, description || '', ingredients || '', instructions || '']
        );

        res.status(201).json({
            message: 'Recette ajoutée avec succès',
            id: result.insertId
        });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

const deleteRecipe = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;

        await db.query(
            'DELETE FROM recette WHERE id=? AND utilisateur_id=?',
            [id, userId]
        );

        res.status(200).json({ message: 'Recette supprimée avec succès' });
    } catch (error) {
        res.status(500).json({ message: 'Erreur serveur', error: error.message });
    }
};

module.exports = { getRecipes, addRecipe, deleteRecipe };