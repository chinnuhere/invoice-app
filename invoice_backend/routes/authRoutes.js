const express = require('express');
const router = express.Router();
const { signup, login, getDashboard } = require('../controllers/authController');
const authenticateToken = require('../middleware/authMiddleware');

// Health check
router.get('/', (req, res) => {
  res.send('Backend Running');
});

// Auth routes
router.post('/signup', signup);
router.post('/login', login);

// Protected routes
router.get('/dashboard', authenticateToken, getDashboard);

module.exports = router;
