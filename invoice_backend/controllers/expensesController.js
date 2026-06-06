const pool = require('../db');
const logger = require('../utils/logger');

// Get all expenses for the authenticated user
const getExpenses = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      'SELECT * FROM expenses WHERE user_id = $1 ORDER BY expense_date DESC',
      [userId]
    );

    res.json(result.rows);
  } catch (error) {
    logger.error('Get expenses error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Get a single expense by ID
const getExpenseById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'SELECT * FROM expenses WHERE id = $1 AND user_id = $2',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Expense not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Get expense error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Create a new expense
const createExpense = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { description, amount, category, expense_date, notes } = req.body;

    // Validate required fields
    if (!description) {
      return res.status(400).json({ error: 'Description is required' });
    }

    if (!amount) {
      return res.status(400).json({ error: 'Amount is required' });
    }

    if (!expense_date) {
      return res.status(400).json({ error: 'Expense date is required' });
    }

    const result = await pool.query(
      'INSERT INTO expenses (user_id, description, amount, category, expense_date, notes) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [userId, description, amount, category, expense_date, notes]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    logger.error('Create expense error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Update an expense
const updateExpense = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const { description, amount, category, expense_date, notes } = req.body;

    // Validate required fields
    if (!description) {
      return res.status(400).json({ error: 'Description is required' });
    }

    if (!amount) {
      return res.status(400).json({ error: 'Amount is required' });
    }

    if (!expense_date) {
      return res.status(400).json({ error: 'Expense date is required' });
    }

    const result = await pool.query(
      'UPDATE expenses SET description = $1, amount = $2, category = $3, expense_date = $4, notes = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 AND user_id = $7 RETURNING *',
      [description, amount, category, expense_date, notes, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Expense not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Update expense error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Delete an expense
const deleteExpense = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'DELETE FROM expenses WHERE id = $1 AND user_id = $2 RETURNING *',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Expense not found' });
    }

    res.json({ message: 'Expense deleted successfully' });
  } catch (error) {
    logger.error('Delete expense error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getExpenses,
  getExpenseById,
  createExpense,
  updateExpense,
  deleteExpense
};
