const express = require('express');
const router = express.Router();
const { getItems, createItem, deleteItem } = require('../controllers/itemsController');
const authenticateToken = require('../middleware/authMiddleware');

router.get('/', authenticateToken, getItems);
router.post('/', authenticateToken, createItem);
router.delete('/:id', authenticateToken, deleteItem);

module.exports = router;
