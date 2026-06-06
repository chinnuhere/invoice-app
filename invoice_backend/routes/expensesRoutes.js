const express = require('express');
const router = express.Router();
const { getExpenses, getExpenseById, createExpense, updateExpense, deleteExpense } = require('../controllers/expensesController');
const authenticateToken = require('../middleware/authMiddleware');

// All routes are protected
router.use(authenticateToken);

// CRUD routes
router.get('/', getExpenses);
router.get('/:id', getExpenseById);
router.post('/', createExpense);
router.put('/:id', updateExpense);
router.delete('/:id', deleteExpense);

module.exports = router;
