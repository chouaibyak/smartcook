const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const inventoryController = require('../controllers/inventoryController');

// Toutes les routes inventory ci-dessous nécessitent un token JWT
router.use(authMiddleware);

// Endpoints (Sémantique claire axée sur les ingrédients)
router.get('/', inventoryController.getAllIngredients || inventoryController.getInventory);
router.post('/', inventoryController.addIngredient || inventoryController.addItem);
router.put('/:id', inventoryController.updateIngredient || inventoryController.updateItem);
router.delete('/:id', inventoryController.deleteIngredient || inventoryController.deleteItem);

module.exports = router;