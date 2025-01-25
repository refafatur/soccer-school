const mysql = require('mysql2/promise');

// Konfigurasi database
const pool = mysql.createPool({
  port: 3306,
  user: 'root',
  password: '',
  database: 'soccer_school',
  waitForConnections: true,
  connectionLimit: 1,
  queueLimit: 0,
  connectTimeout: 5000
});

// Basic connection test
pool.getConnection()
  .then(connection => {
    console.log('Database terhubung!');
    connection.release();
  })
  .catch(err => {
    console.error('Error koneksi database:', err.message);
  });

module.exports = pool;