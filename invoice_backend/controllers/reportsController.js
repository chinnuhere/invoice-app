const pool = require('../db');
const logger = require('../utils/logger');

// Get monthly report (invoices and expenses for a specific month)
const getMonthlyReport = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { year, month } = req.query;

    if (!year || !month) {
      return res.status(400).json({ error: 'Year and month parameters are required' });
    }

    // Get invoices for the month
    const invoicesResult = await pool.query(
      `SELECT * FROM invoices 
       WHERE user_id = $1 
       AND EXTRACT(YEAR FROM issue_date) = $2 
       AND EXTRACT(MONTH FROM issue_date) = $3
       ORDER BY issue_date DESC`,
      [userId, year, month]
    );

    // Get expenses for the month
    const expensesResult = await pool.query(
      `SELECT * FROM expenses 
       WHERE user_id = $1 
       AND EXTRACT(YEAR FROM expense_date) = $2 
       AND EXTRACT(MONTH FROM expense_date) = $3
       ORDER BY expense_date DESC`,
      [userId, year, month]
    );

    // Calculate totals
    const totalRevenue = invoicesResult.rows.reduce((sum, inv) => sum + (parseFloat(inv.total) || 0), 0);
    const totalExpenses = expensesResult.rows.reduce((sum, exp) => sum + (parseFloat(exp.amount) || 0), 0);
    const netProfit = totalRevenue - totalExpenses;

    // Group invoices by status
    const invoicesByStatus = invoicesResult.rows.reduce((acc, inv) => {
      const status = inv.status || 'draft';
      acc[status] = (acc[status] || 0) + 1;
      return acc;
    }, {});

    // Group expenses by category
    const expensesByCategory = expensesResult.rows.reduce((acc, exp) => {
      const category = exp.category || 'Other';
      acc[category] = (acc[category] || 0) + parseFloat(exp.amount);
      return acc;
    }, {});

    res.json({
      year: parseInt(year),
      month: parseInt(month),
      invoices: invoicesResult.rows,
      expenses: expensesResult.rows,
      summary: {
        totalRevenue,
        totalExpenses,
        netProfit,
        invoiceCount: invoicesResult.rows.length,
        expenseCount: expensesResult.rows.length,
        invoicesByStatus,
        expensesByCategory,
      },
    });
  } catch (error) {
    logger.error('Get monthly report error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Get yearly report (invoices and expenses for a specific year)
const getYearlyReport = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { year } = req.query;

    if (!year) {
      return res.status(400).json({ error: 'Year parameter is required' });
    }

    // Get invoices for the year
    const invoicesResult = await pool.query(
      `SELECT * FROM invoices 
       WHERE user_id = $1 
       AND EXTRACT(YEAR FROM issue_date) = $2
       ORDER BY issue_date DESC`,
      [userId, year]
    );

    // Get expenses for the year
    const expensesResult = await pool.query(
      `SELECT * FROM expenses 
       WHERE user_id = $1 
       AND EXTRACT(YEAR FROM expense_date) = $2
       ORDER BY expense_date DESC`,
      [userId, year]
    );

    // Calculate totals
    const totalRevenue = invoicesResult.rows.reduce((sum, inv) => sum + (parseFloat(inv.total) || 0), 0);
    const totalExpenses = expensesResult.rows.reduce((sum, exp) => sum + (parseFloat(exp.amount) || 0), 0);
    const netProfit = totalRevenue - totalExpenses;

    // Group invoices by month
    const invoicesByMonth = {};
    const expensesByMonth = {};
    
    for (let i = 1; i <= 12; i++) {
      invoicesByMonth[i] = 0;
      expensesByMonth[i] = 0;
    }

    invoicesResult.rows.forEach(inv => {
      const month = new Date(inv.issue_date).getMonth() + 1;
      invoicesByMonth[month] += parseFloat(inv.total) || 0;
    });

    expensesResult.rows.forEach(exp => {
      const month = new Date(exp.expense_date).getMonth() + 1;
      expensesByMonth[month] += parseFloat(exp.amount) || 0;
    });

    // Group invoices by status
    const invoicesByStatus = invoicesResult.rows.reduce((acc, inv) => {
      const status = inv.status || 'draft';
      acc[status] = (acc[status] || 0) + 1;
      return acc;
    }, {});

    // Group expenses by category
    const expensesByCategory = expensesResult.rows.reduce((acc, exp) => {
      const category = exp.category || 'Other';
      acc[category] = (acc[category] || 0) + parseFloat(exp.amount);
      return acc;
    }, {});

    res.json({
      year: parseInt(year),
      invoices: invoicesResult.rows,
      expenses: expensesResult.rows,
      summary: {
        totalRevenue,
        totalExpenses,
        netProfit,
        invoiceCount: invoicesResult.rows.length,
        expenseCount: expensesResult.rows.length,
        invoicesByMonth,
        expensesByMonth,
        invoicesByStatus,
        expensesByCategory,
      },
    });
  } catch (error) {
    logger.error('Get yearly report error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Get revenue report (invoice payments and trends)
const getRevenueReport = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { startDate, endDate } = req.query;

    let dateFilter = '';
    const queryParams = [userId];

    if (startDate && endDate) {
      dateFilter = `AND issue_date >= $2 AND issue_date <= $3`;
      queryParams.push(startDate, endDate);
    }

    // Get paid invoices within date range
    const paidInvoicesResult = await pool.query(
      `SELECT * FROM invoices 
       WHERE user_id = $1 
       AND status = 'paid'
       ${dateFilter}
       ORDER BY issue_date DESC`,
      queryParams
    );

    // Get all invoices within date range
    const allInvoicesResult = await pool.query(
      `SELECT * FROM invoices 
       WHERE user_id = $1 
       ${dateFilter}
       ORDER BY issue_date DESC`,
      queryParams
    );

    // Calculate revenue metrics
    const totalRevenue = paidInvoicesResult.rows.reduce((sum, inv) => sum + (parseFloat(inv.total) || 0), 0);
    const totalInvoiced = allInvoicesResult.rows.reduce((sum, inv) => sum + (parseFloat(inv.total) || 0), 0);
    const pendingRevenue = totalInvoiced - totalRevenue;

    // Group by month for trend analysis
    const revenueByMonth = {};
    
    paidInvoicesResult.rows.forEach(inv => {
      const date = new Date(inv.issue_date);
      const key = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
      revenueByMonth[key] = (revenueByMonth[key] || 0) + parseFloat(inv.total);
    });

    // Calculate average invoice value
    const avgInvoiceValue = paidInvoicesResult.rows.length > 0 
      ? totalRevenue / paidInvoicesResult.rows.length 
      : 0;

    // Get top clients by revenue
    const clientRevenue = {};
    paidInvoicesResult.rows.forEach(inv => {
      const clientName = inv.client_name || 'Unknown';
      clientRevenue[clientName] = (clientRevenue[clientName] || 0) + parseFloat(inv.total);
    });

    const topClients = Object.entries(clientRevenue)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([name, revenue]) => ({ client: name, revenue }));

    res.json({
      period: {
        startDate: startDate || null,
        endDate: endDate || null,
      },
      paidInvoices: paidInvoicesResult.rows,
      allInvoices: allInvoicesResult.rows,
      summary: {
        totalRevenue,
        totalInvoiced,
        pendingRevenue,
        paidInvoiceCount: paidInvoicesResult.rows.length,
        totalInvoiceCount: allInvoicesResult.rows.length,
        avgInvoiceValue,
        revenueByMonth,
        topClients,
      },
    });
  } catch (error) {
    logger.error('Get revenue report error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getMonthlyReport,
  getYearlyReport,
  getRevenueReport
};
