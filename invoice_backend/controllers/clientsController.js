const pool = require('../db');
const logger = require('../utils/logger');

// Get all clients for the authenticated user
const getClients = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      'SELECT * FROM clients WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );

    res.json(result.rows);
  } catch (error) {
    logger.error('Get clients error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Get a single client by ID
const getClientById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'SELECT * FROM clients WHERE id = $1 AND user_id = $2',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Client not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Get client error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Create a new client
const createClient = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { name, email, phone, company, address } = req.body;

    // Validate required fields
    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    const result = await pool.query(
      'INSERT INTO clients (user_id, name, email, phone, company, address) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [userId, name, email, phone, company, address]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    logger.error('Create client error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Update a client
const updateClient = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const { name, email, phone, company, address } = req.body;

    // Validate required fields
    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    const result = await pool.query(
      'UPDATE clients SET name = $1, email = $2, phone = $3, company = $4, address = $5, updated_at = CURRENT_TIMESTAMP WHERE id = $6 AND user_id = $7 RETURNING *',
      [name, email, phone, company, address, id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Client not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Update client error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Delete a client
const deleteClient = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'DELETE FROM clients WHERE id = $1 AND user_id = $2 RETURNING *',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Client not found' });
    }

    res.json({ message: 'Client deleted successfully' });
  } catch (error) {
    logger.error('Delete client error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getClients,
  getClientById,
  createClient,
  updateClient,
  deleteClient
};
