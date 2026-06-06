const pool = require('../db');
const logger = require('../utils/logger');

// Get dashboard summary
const getSummary = async (req, res) => {
  try {
    // Get total clients
    const clientsResult = await pool.query(
      'SELECT COUNT(*) as count FROM clients'
    );
    const totalClients = parseInt(clientsResult.rows[0].count);

    // Get total invoices
    const invoicesResult = await pool.query(
      'SELECT COUNT(*) as count FROM invoices'
    );
    const totalInvoices = parseInt(invoicesResult.rows[0].count);

    // Get total revenue (sum of paid invoices)
    const revenueResult = await pool.query(
      "SELECT COALESCE(SUM(amount), 0) as total FROM invoices WHERE status = 'paid'"
    );
    const revenue = parseFloat(revenueResult.rows[0].total);

    // Get total expenses
    const expensesResult = await pool.query(
      'SELECT COALESCE(SUM(amount), 0) as total FROM expenses'
    );
    const expenses = parseFloat(expensesResult.rows[0].total);

    res.json({
      totalClients,
      totalInvoices,
      revenue,
      expenses,
    });
  } catch (error) {
    logger.error('Dashboard summary error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getSummary
};
