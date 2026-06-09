const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const chatController = require('../controllers/chatController');

router.get('/', authMiddleware, chatController.getConversations);
router.get('/conversations', authMiddleware, chatController.getConversations);
router.get(
  '/conversations/:id/messages',
  authMiddleware,
  chatController.getConversationMessages
);
router.post('/', authMiddleware, chatController.sendMessage);

module.exports = router;
