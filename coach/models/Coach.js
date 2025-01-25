const Sequelize = require('sequelize');
const db = require('../config/database');

const Coach = db.define('coach', {
  id_coach: {
    type: Sequelize.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: Sequelize.STRING,
    allowNull: false
  },
  email: {
    type: Sequelize.STRING,
    allowNull: false,
    unique: true
  },
  password: {
    type: Sequelize.STRING,
    allowNull: false
  },
  phone: Sequelize.STRING,
  address: Sequelize.TEXT
});

module.exports = Coach; 