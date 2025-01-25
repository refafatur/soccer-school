const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');
const coachRoutes = require('./routes/coach');
const config = require('./config/config');

const app = express();

app.use(cors());
app.use(express.json());

// Connect to MySQL
const connection = mysql.createConnection(config.database);

// Routes
app.use('/api/coach', coachRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});