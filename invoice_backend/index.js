require('dotenv').config();
const logger = require('./utils/logger');
const errorMiddleware = require('./middleware/errorMiddleware');

// Validate required environment variables on startup
const hasDbConfig = process.env.DB_PASSWORD || process.env.DATABASE_URL;
const hasJwtSecret = process.env.JWT_SECRET;

const missingEnvVars = [];
if (!hasDbConfig) {
  missingEnvVars.push('DB_PASSWORD or DATABASE_URL');
}
if (!hasJwtSecret) {
  missingEnvVars.push('JWT_SECRET');
}

if (missingEnvVars.length > 0) {
  logger.error('CRITICAL STARTUP ERROR: Missing required environment variables:');
  missingEnvVars.forEach(varName => {
    logger.error(`  - ${varName}`);
  });
  logger.error('Application refusing to start. Please configure .env file.');
  process.exit(1);
}

const express = require('express');
const cors = require('cors');
const pool = require('./db');
const authRoutes = require('./routes/authRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const clientsRoutes = require('./routes/clientsRoutes');
const invoicesRoutes = require('./routes/invoicesRoutes');
const expensesRoutes = require('./routes/expensesRoutes');
const reportsRoutes = require('./routes/reportsRoutes');
const businessProfileRoutes = require('./routes/businessProfileRoutes');
const itemsRoutes = require('./routes/itemsRoutes');

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/', authRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/clients', clientsRoutes);
app.use('/invoices', invoicesRoutes);
app.use('/expenses', expensesRoutes);
app.use('/reports', reportsRoutes);
app.use('/business-profile', businessProfileRoutes);
app.use('/items', itemsRoutes);

// Global Error Handler Middleware
app.use(errorMiddleware);

// Handle uncaught exceptions and unhandled promise rejections
process.on('uncaughtException', (err) => {
  logger.error('UNCAUGHT EXCEPTION:', err.message, err.stack);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('UNHANDLED REJECTION:', reason);
});

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    logger.error('Database connection error:', err);
  } else {
    logger.info('Database connected successfully.');
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  logger.info(`Server running on port ${PORT}`);
});