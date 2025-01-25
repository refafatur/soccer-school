const Sequelize = require('sequelize');
const db = require('../config/database');

const Assessment = db.define('assessment', {
  id_assessment: {
    type: Sequelize.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  student_name: {
    type: Sequelize.STRING,
    allowNull: false
  },
  aspect_id: {
    type: Sequelize.INTEGER,
    allowNull: false
  },
  score: {
    type: Sequelize.INTEGER,
    allowNull: false
  },
  note: Sequelize.TEXT,
  coach_id: {
    type: Sequelize.INTEGER,
    allowNull: false
  }
});

module.exports = Assessment; 