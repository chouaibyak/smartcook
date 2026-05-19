const express = require('express');
const router = express.Router();
const alimentCtrl = require('../controllers/alimentController');
const authMiddleware = require('../middleware/authMiddleware');
router.get('/analyze', alimentCtrl.getNutritionInfo);

router.post('/add', authMiddleware, alimentCtrl.saveAliment);

module.exports = router;