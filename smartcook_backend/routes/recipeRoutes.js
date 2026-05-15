const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');
const authMiddleware = require('../middleware/authMiddleware');
const Recipe = require('../models/Recipe');

// Route pour forcer la génération (quand l'utilisateur clique sur "Rafraîchir")
router.post('/recipes/refresh', authMiddleware, recipeController.refreshRecipes);

// Route pour afficher les recettes déjà stockées
router.get('/recipes', authMiddleware, async (req, res) => {
    try {
        const recipes = await Recipe.findAllByUserId(req.userId);
        res.json(recipes);
    } catch (error) {
        console.error("Get Recipes Error:", error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
