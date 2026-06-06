const pool = require('../db');
const logger = require('../utils/logger');

// Get all invoices for the authenticated user
const getInvoices = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT i.*, c.name as client_name, c.email as client_email 
       FROM invoices i 
       LEFT JOIN clients c ON i.client_id = c.id 
       WHERE i.user_id = $1 
       ORDER BY i.created_at DESC`,
      [userId]
    );

    res.json(result.rows);
  } catch (error) {
    logger.error('Get invoices error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Get a single invoice by ID with its items
const getInvoiceById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const invoiceResult = await pool.query(
      `SELECT i.*, c.name as client_name, c.email as client_email, c.phone as client_phone, c.company as client_company, c.address as client_address 
       FROM invoices i 
       LEFT JOIN clients c ON i.client_id = c.id 
       WHERE i.id = $1 AND i.user_id = $2`,
      [id, userId]
    );

    if (invoiceResult.rows.length === 0) {
      return res.status(404).json({ error: 'Invoice not found' });
    }

    const itemsResult = await pool.query(
      'SELECT * FROM invoice_items WHERE invoice_id = $1 ORDER BY id',
      [id]
    );

    const invoice = invoiceResult.rows[0];
    invoice.items = itemsResult.rows;

    res.json(invoice);
  } catch (error) {
    logger.error('Get invoice error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Create a new invoice with items
const createInvoice = async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const userId = req.user.userId;
    const { client_id, invoice_number, issue_date, due_date, status, notes, items } = req.body;

    // Validate required fields
    if (!client_id || !invoice_number || !issue_date || !due_date) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Calculate totals
    let subtotal = 0;
    if (items && items.length > 0) {
      items.forEach(item => {
        subtotal += (item.quantity || 0) * (item.unit_price || 0);
      });
    }

    const tax = 0; // Can be calculated based on tax rate if needed
    const total = subtotal + tax;

    const invoiceResult = await client.query(
      'INSERT INTO invoices (user_id, client_id, invoice_number, issue_date, due_date, status, subtotal, tax, total, notes) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *',
      [userId, client_id, invoice_number, issue_date, due_date, status || 'draft', subtotal, tax, total, notes]
    );

    const invoiceId = invoiceResult.rows[0].id;

    // Insert invoice items
    if (items && items.length > 0) {
      for (const item of items) {
        const itemTotal = (item.quantity || 0) * (item.unit_price || 0);
        await client.query(
          'INSERT INTO invoice_items (invoice_id, description, quantity, unit_price, total) VALUES ($1, $2, $3, $4, $5)',
          [invoiceId, item.description, item.quantity, item.unit_price, itemTotal]
        );
      }
    }

    await client.query('COMMIT');

    // Fetch the complete invoice with items
    const itemsResult = await pool.query(
      'SELECT * FROM invoice_items WHERE invoice_id = $1 ORDER BY id',
      [invoiceId]
    );

    const invoice = invoiceResult.rows[0];
    invoice.items = itemsResult.rows;

    res.status(201).json(invoice);
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Create invoice error:', error);
    res.status(500).json({ error: 'Internal server error' });
  } finally {
    client.release();
  }
};

// Update an invoice with items
const updateInvoice = async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const { id } = req.params;
    const userId = req.user.userId;
    const { client_id, invoice_number, issue_date, due_date, status, notes, items } = req.body;

    // Validate required fields
    if (!client_id || !invoice_number || !issue_date || !due_date) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Calculate totals
    let subtotal = 0;
    if (items && items.length > 0) {
      items.forEach(item => {
        subtotal += (item.quantity || 0) * (item.unit_price || 0);
      });
    }

    const tax = 0;
    const total = subtotal + tax;

    const invoiceResult = await client.query(
      'UPDATE invoices SET client_id = $1, invoice_number = $2, issue_date = $3, due_date = $4, status = $5, subtotal = $6, tax = $7, total = $8, notes = $9, updated_at = CURRENT_TIMESTAMP WHERE id = $10 AND user_id = $11 RETURNING *',
      [client_id, invoice_number, issue_date, due_date, status || 'draft', subtotal, tax, total, notes, id, userId]
    );

    if (invoiceResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Invoice not found' });
    }

    // Delete existing items
    await client.query('DELETE FROM invoice_items WHERE invoice_id = $1', [id]);

    // Insert new items
    if (items && items.length > 0) {
      for (const item of items) {
        const itemTotal = (item.quantity || 0) * (item.unit_price || 0);
        await client.query(
          'INSERT INTO invoice_items (invoice_id, description, quantity, unit_price, total) VALUES ($1, $2, $3, $4, $5)',
          [id, item.description, item.quantity, item.unit_price, itemTotal]
        );
      }
    }

    await client.query('COMMIT');

    // Fetch the complete invoice with items
    const itemsResult = await pool.query(
      'SELECT * FROM invoice_items WHERE invoice_id = $1 ORDER BY id',
      [id]
    );

    const invoice = invoiceResult.rows[0];
    invoice.items = itemsResult.rows;

    res.json(invoice);
  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Update invoice error:', error);
    res.status(500).json({ error: 'Internal server error' });
  } finally {
    client.release();
  }
};

// Delete an invoice
const deleteInvoice = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      'DELETE FROM invoices WHERE id = $1 AND user_id = $2 RETURNING *',
      [id, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Invoice not found' });
    }

    res.json({ message: 'Invoice deleted successfully' });
  } catch (error) {
    logger.error('Delete invoice error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getInvoices,
  getInvoiceById,
  createInvoice,
  updateInvoice,
  deleteInvoice
};
