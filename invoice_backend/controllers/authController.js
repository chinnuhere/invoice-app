const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../db');
const logger = require('../utils/logger');

// Signup controller
const signup = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validate email and password
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Insert user into database
    const result = await pool.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email',
      [name, email, hashedPassword]
    );

    res.status(201).json({ 
      message: 'User created successfully',
      user: result.rows[0]
    });
  } catch (error) {
    if (error.code === '23505') { // Unique violation
      res.status(400).json({ error: 'Email already exists' });
    } else {
      logger.error('Signup error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
};

// Login controller
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate email and password
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user by email
    const result = await pool.query(
      'SELECT id, name, email, password FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // Compare password
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    // Return token and user info (without password)
    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    });
  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Dashboard controller
const getDashboard = (req, res) => {
  res.json({
    message: 'Welcome to dashboard',
    user: req.user
  });
};

module.exports = {
  signup,
  login,
  getDashboard
};
