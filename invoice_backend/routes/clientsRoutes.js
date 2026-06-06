const express = require('express');
const router = express.Router();
const { getClients, getClientById, createClient, updateClient, deleteClient } = require('../controllers/clientsController');
const authenticateToken = require('../middleware/authMiddleware');

// All routes are protected
router.use(authenticateToken);

// CRUD routes
router.get('/', getClients);
router.get('/:id', getClientById);
router.post('/', createClient);
router.put('/:id', updateClient);
router.delete('/:id', deleteClient);

module.exports = router;
