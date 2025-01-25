const db = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const orangtuaController = {
  // untuk login
  login: async (req, res) => {
    try {
      const { email, date_birth } = req.body;
      
      const query = 'SELECT * FROM student WHERE email = ? AND date_birth = ?';
      db.query(query, [email, date_birth], async (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Kesalahan saat login", error: err });
        }
        
        if (results.length === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }

        const token = jwt.sign({ 
          id: results[0].id,
          email: results[0].email,
          date_birth: results[0].date_birth
        }, 'kunci_rahasia', { expiresIn: '1h' });
        
        res.json({ 
          message: "Login berhasil",
          token,
          user: {
            id: results[0].id,
            email: results[0].email,
            date_birth: results[0].date_birth
          }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Kesalahan server", error: error });
    }
  },

  read_assessment: async (req, res) => {
    try {
      const query = 'SELECT * FROM assessment';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data assessment", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  read_assessment_setting: async (req, res) => {
    try {
      const query = 'SELECT * FROM assessment_setting';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data assessment setting", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  read_information: async (req, res) => {
    try {
      const query = 'SELECT * FROM information';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data information", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  read_schedule: async (req, res) => {
    try {
      const query = 'SELECT * FROM schedule';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data schedule", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  update_student: async (req, res) => {
    try {
      const { reg_id_student } = req.params;
      const { id_student, name, date_birth, gender, email, nohp, registration_date, status } = req.body;
      const photo = req.file ? req.file.path : null; // Ubah default photo menjadi null jika kosong
      const query = `
        UPDATE student 
        SET 
          id_student = ?, 
          name = ?, 
          date_birth = ?, 
          gender = ?, 
          photo = ?, 
          email = ?, 
          nohp = ?, 
          registration_date = ?, 
          status = ? 
        WHERE reg_id_student = ?`;
      db.query(
        query,
        [id_student, name, date_birth, gender, photo, email, nohp, registration_date, status, reg_id_student],
        (err, results) => {
          if (err) {
            return res.status(500).json({ message: "Error saat memperbarui data siswa", error: err });
          }
          if (results.affectedRows === 0) {
            return res.status(404).json({ message: "Data siswa tidak ditemukan" });
          }
          res.json({ message: "Data siswa berhasil diperbarui" });
        }
      );
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },


  
};

module.exports = orangtuaController; 