const mysql = require('mysql2');

const pool = mysql.createPool({
  port: 3306,
  user: 'root',
  password: '',  // Updated password
  database: 'soccer_school',
  waitForConnections: true,
  connectionLimit: 1,
  queueLimit: 0,
  connectTimeout: 5000
}).promise();

// Basic error handling
pool.on('error', (err) => {
  console.error('Database error:', err.message);
});

module.exports = pool;