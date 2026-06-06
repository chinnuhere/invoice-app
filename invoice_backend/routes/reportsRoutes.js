const express = require('express');
const router = express.Router();
const { getMonthlyReport, getYearlyReport, getRevenueReport } = require('../controllers/reportsController');
const authenticateToken = require('../middleware/authMiddleware');

// All routes are protected
router.use(authenticateToken);

// Report routes
router.get('/monthly', getMonthlyReport);
router.get('/yearly', getYearlyReport);
router.get('/revenue', getRevenueReport);

module.exports = router;
