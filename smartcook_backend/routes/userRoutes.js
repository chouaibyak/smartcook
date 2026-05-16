const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const auth = require('../middleware/authMiddleware');

// Route protégée par le middleware 'auth'
router.post('/complete-profile', auth, userController.updateInitialProfile);
router.get('/profile', auth, userController.getProfile);

module.exports = router;
