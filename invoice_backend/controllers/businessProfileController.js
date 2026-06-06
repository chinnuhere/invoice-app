const pool = require('../db');
const logger = require('../utils/logger');

// Get business profile
const getBusinessProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const result = await pool.query(
      'SELECT * FROM business_profiles WHERE user_id = $1',
      [userId]
    );
    
    if (result.rows.length === 0) {
      return res.json(null);
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Get business profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Create business profile
const createBusinessProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      business_name,
      email,
      phone,
      address,
      city,
      state,
      zip,
      country,
      tax_id,
      registration_number,
      bank_name,
      account_number,
      routing_number,
    } = req.body;

    if (!business_name) {
      return res.status(400).json({ error: 'Business name is required' });
    }

    const result = await pool.query(
      `INSERT INTO business_profiles 
       (user_id, business_name, email, phone, address, city, state, zip, country, 
        tax_id, registration_number, bank_name, account_number, routing_number)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING *`,
      [userId, business_name, email, phone, address, city, state, zip, country,
       tax_id, registration_number, bank_name, account_number, routing_number]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    logger.error('Create business profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Update business profile
const updateBusinessProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      business_name,
      email,
      phone,
      address,
      city,
      state,
      zip,
      country,
      tax_id,
      registration_number,
      bank_name,
      account_number,
      routing_number,
    } = req.body;

    if (!business_name) {
      return res.status(400).json({ error: 'Business name is required' });
    }

    const result = await pool.query(
      `UPDATE business_profiles 
       SET business_name = $1, email = $2, phone = $3, address = $4, city = $5, 
           state = $6, zip = $7, country = $8, tax_id = $9, registration_number = $10,
           bank_name = $11, account_number = $12, routing_number = $13, updated_at = CURRENT_TIMESTAMP
       WHERE user_id = $14
       RETURNING *`,
      [business_name, email, phone, address, city, state, zip, country,
       tax_id, registration_number, bank_name, account_number, routing_number, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Business profile not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Update business profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getBusinessProfile,
  createBusinessProfile,
  updateBusinessProfile
};
