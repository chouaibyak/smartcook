const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventoryController');
const authMiddleware = require('../middleware/authMiddleware');

// Toutes les routes inventory nécessitent un token JWT
router.get('/',        authMiddleware, inventoryController.getInventory);
router.post('/',       authMiddleware, inventoryController.addItem);
router.put('/:id',     authMiddleware, inventoryController.updateItem);
router.delete('/:id',  authMiddleware, inventoryController.deleteItem);

module.exports = router;