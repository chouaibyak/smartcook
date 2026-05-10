const express = require('express');
const router = express.Router();
const shoppingController = require('../controllers/shoppingController');
const authMiddleware = require('../middleware/authMiddleware');
router.get('/', authMiddleware, shoppingController.getShoppingList);
router.post('/', authMiddleware, shoppingController.addItem);
router.delete('/:id', authMiddleware, shoppingController.deleteItem);
module.exports = router;