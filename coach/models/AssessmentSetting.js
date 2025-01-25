const Sequelize = require('sequelize');
const db = require('../config/database');

const AssessmentSetting = db.define('assessment_setting', {
  id_assessment_setting: {
    type: Sequelize.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  name: {
    type: Sequelize.STRING,
    allowNull: false
  },
  description: Sequelize.TEXT,
  min_score: {
    type: Sequelize.INTEGER,
    allowNull: false
  },
  max_score: {
    type: Sequelize.INTEGER,
    allowNull: false
  }
});

module.exports = AssessmentSetting; 