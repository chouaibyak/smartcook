const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');
const authMiddleware = require('../middleware/authMiddleware');
router.get('/', authMiddleware, recipeController.getRecipes);
router.post('/', authMiddleware, recipeController.addRecipe);
router.delete('/:id', authMiddleware, recipeController.deleteRecipe);
module.exports = router;