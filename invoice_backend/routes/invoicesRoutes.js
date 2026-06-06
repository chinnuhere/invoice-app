const express = require('express');
const router = express.Router();
const { getInvoices, getInvoiceById, createInvoice, updateInvoice, deleteInvoice } = require('../controllers/invoicesController');
const authenticateToken = require('../middleware/authMiddleware');

// All routes are protected
router.use(authenticateToken);

// CRUD routes
router.get('/', getInvoices);
router.get('/:id', getInvoiceById);
router.post('/', createInvoice);
router.put('/:id', updateInvoice);
router.delete('/:id', deleteInvoice);

module.exports = router;
