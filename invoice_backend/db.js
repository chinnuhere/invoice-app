const { Pool } = require('pg');
require('dotenv').config();

const connectionString = process.env.DATABASE_URL;

const pool = new Pool({
  connectionString,
  user: connectionString ? undefined : (process.env.DB_USER || 'postgres'),
  host: connectionString ? undefined : (process.env.DB_HOST || 'localhost'),
  database: connectionString ? undefined : (process.env.DB_NAME || 'invoice_app'),
  password: connectionString ? undefined : process.env.DB_PASSWORD,
  port: connectionString ? undefined : parseInt(process.env.DB_PORT || '5432', 10),
  ssl: connectionString ? { rejectUnauthorized: false } : false
});

module.exports = pool;
 