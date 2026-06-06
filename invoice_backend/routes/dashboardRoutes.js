const express = require('express');
const router = express.Router();
const { getSummary } = require('../controllers/dashboardController');
const authenticateToken = require('../middleware/authMiddleware');

// Dashboard routes
router.get('/summary', authenticateToken, getSummary);

module.exports = router;
