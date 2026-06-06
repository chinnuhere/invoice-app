const express = require('express');
const router = express.Router();
const { getBusinessProfile, createBusinessProfile, updateBusinessProfile } = require('../controllers/businessProfileController');
const authenticateToken = require('../middleware/authMiddleware');

// All routes are protected
router.use(authenticateToken);

// Business profile routes
router.get('/', getBusinessProfile);
router.post('/', createBusinessProfile);
router.put('/', updateBusinessProfile);

module.exports = router;
