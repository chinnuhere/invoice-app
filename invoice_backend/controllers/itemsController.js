const pool = require('../db');
const logger = require('../utils/logger');

// Get all items for the authenticated user
const getItems = async (req, res) => {
  try {
    const userId = req.user.userId;
    const result = await pool.query(
      'SELECT * FROM items WHERE user_id = $1 ORDER BY name ASC',
      [userId]
    );
    res.json(result.rows);
  } catch (error) {
    logger.error('Get items error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Create a new item for the authenticated user
const createItem = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { name, price } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'Item name is required' });
    }

    const itemPrice = parseFloat(price) || 0.0;

    const result = await pool.query(
      'INSERT INTO items (user_id, name, price) VALUES ($1, $2, $3) RETURNING *',
      [userId, name, itemPrice]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    logger.error('Create item error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Delete an item
const deleteItem = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM items WHERE id = $1 AND user_id = $2 RETURNING *',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Item not found' });
    }

    res.json({ message: 'Item deleted successfully' });
  } catch (error) {
    logger.error('Delete item error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getItems,
  createItem,
  deleteItem
};
