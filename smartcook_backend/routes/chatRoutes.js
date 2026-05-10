const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const authMiddleware = require('../middleware/authMiddleware');
router.get('/', authMiddleware, chatController.getMessages);
router.post('/', authMiddleware, chatController.sendMessage);
module.exports = router;