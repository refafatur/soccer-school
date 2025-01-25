const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '', // sesuaikan dengan password MySQL Anda
  database: 'ssb_tiger' // sesuaikan dengan nama database Anda
});

connection.connect((err) => {
  if (err) {
    console.error('Error connecting to database:', err);
    return;
  }
  console.log('Successfully connected to database');
});

module.exports = connection; 