const db = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');

const coachController = {
    //Login Coach
    login: async (req, res) => {
    try {
      const { email, nohp } = req.body;
      
      const query = 'SELECT * FROM coach WHERE email = ? AND nohp = ?';
      db.query(query, [email, nohp], async (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat login", error: err });
        }
        
        if (results.length === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }

        const token = jwt.sign({ 
          id_coach: results[0].id_coach, // Menggunakan id_coach yang benar
          email: results[0].email,
          nohp: results[0].nohp
        }, 'kunci_rahasia', { expiresIn: '1h' });
        
        res.json({ 
          message: "Login berhasil",
          token,
          user: {
            id_coach: results[0].id_coach, // Menggunakan id_coach yang benar
            email: results[0].email,
            nohp: results[0].nohp
          }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Aspect
  read_aspect: async (req, res) => {
    try {
      const query = 'SELECT * FROM aspect';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data aspect", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Aspect Sub
  read_aspect_sub: async (req, res) => {
    try {
      const query = 'SELECT * FROM aspect_sub';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data aspect_sub", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Assessment
  create_assessment: async (req, res) => {
    try {
      const { year_academic, year_assessment, reg_id_student, id_aspect_sub, id_coach, point, ket, date_assessment } = req.body;
      const query = 'INSERT INTO assessment (year_academic, year_assessment, reg_id_student, id_aspect_sub, id_coach, point, ket, date_assessment) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
      db.query(query, [year_academic, year_assessment, reg_id_student, id_aspect_sub, id_coach, point, ket, date_assessment], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat membuat assessment", error: err });
        }
        res.json({ 
          message: "Assessment berhasil dibuat",
          data: { id_assessment: results.insertId, year_academic, year_assessment, reg_id_student, id_aspect_sub, id_coach, point, ket, date_assessment }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
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

  update_assessment: async (req, res) => {
    try {
      const { id_assessment } = req.params;
      const { year_academic, year_assessment, reg_id_student, id_aspect_sub, id_coach, point, ket, date_assessment } = req.body;
      const query = 'UPDATE assessment SET year_academic = ?, year_assessment = ?, reg_id_student = ?, id_aspect_sub = ?, id_coach = ?, point = ?, ket = ?, date_assessment = ? WHERE id_assessment = ?';
      db.query(query, [year_academic, year_assessment, reg_id_student, id_aspect_sub, id_coach, point, ket, date_assessment, id_assessment], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data assessment", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data assessment tidak ditemukan" });
        }
        res.json({ 
          message: "Data assessment berhasil diperbarui",
          data: { id_assessment, year_academic, year_assessment, reg_id_student, id_aspect_sub, id_coach, point, ket, date_assessment }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  delete_assessment: async (req, res) => {
    try {
      const { id_assessment } = req.params;
      const query = 'DELETE FROM assessment WHERE id_assessment = ?';
      db.query(query, [id_assessment], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data assessment", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data assessment tidak ditemukan" });
        }
        res.json({ message: "Data assessment berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Assesment Setting
  create_assessment_setting: async (req, res) => {
    try {
      const { year_academic, year_assessment, id_coach, id_aspect_sub, bobot } = req.body;
      const query = 'INSERT INTO assessment_setting (year_academic, year_assessment, id_coach, id_aspect_sub, bobot) VALUES (?, ?, ?, ?, ?)';
      db.query(query, [year_academic, year_assessment, id_coach, id_aspect_sub, bobot], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat membuat assessment setting", error: err });
        }
        res.json({ 
          message: "Assessment setting berhasil dibuat",
          data: { id_assessment_setting: results.insertId, year_academic, year_assessment, id_coach, id_aspect_sub, bobot }
        });
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

  update_assessment_setting: async (req, res) => {
    try {
      const { id_assessment_setting } = req.params;
      const { year_academic, year_assessment, id_coach, id_aspect_sub, bobot } = req.body;
      const query = 'UPDATE assessment_setting SET year_academic = ?, year_assessment = ?, id_coach = ?, id_aspect_sub = ?, bobot = ? WHERE id_assessment_setting = ?';
      db.query(query, [year_academic, year_assessment, id_coach, id_aspect_sub, bobot, id_assessment_setting], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data assessment setting", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data assessment setting tidak ditemukan" });
        }
        res.json({ 
          message: "Data assessment setting berhasil diperbarui",
          data: { id_assessment_setting, year_academic, year_assessment, id_coach, id_aspect_sub, bobot }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  delete_assessment_setting: async (req, res) => {
    try {
      const { id_assessment_setting } = req.params;
      const query = 'DELETE FROM assessment_setting WHERE id_assessment_setting = ?';
      db.query(query, [id_assessment_setting], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data assessment setting", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data assessment setting tidak ditemukan" });
        }
        res.json({ message: "Data assessment setting berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Information
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

  //Point Rate
  read_point_rate: async (req, res) => {
    try {
      const query = 'SELECT * FROM point_rate';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data point_rate", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Schedule
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

  //Coach
  update_coach: async (req, res) => {
    try {
      const { id_coach } = req.params;
      const { name_coach, coach_department, years_coach, email, nohp, status_coach } = req.body;
      
      const query = `
        UPDATE coach 
        SET 
          name_coach = ?, 
          coach_department = ?, 
          years_coach = ?, 
          email = ?, 
          nohp = ?, 
          status_coach = ? 
        WHERE id_coach = ?`;
      
      db.query(
        query,
        [name_coach, coach_department, years_coach, email, nohp, status_coach, id_coach],
        (err, results) => {
          if (err) {
            return res.status(500).json({ message: "Error saat memperbarui data pelatih", error: err });
          }
          if (results.affectedRows === 0) {
            return res.status(404).json({ message: "Data pelatih tidak ditemukan" });
          }
          res.json({ 
            message: "Data pelatih berhasil diperbarui",
            data: {
              id_coach,
              name_coach,
              coach_department,
              years_coach,
              email,
              nohp,
              status_coach
            }
          });
        }
      );
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  read_point_rate: async (req, res) => {
    try {
      const query = 'SELECT * FROM point_rate';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data point_rate", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  update_coach: async (req, res) => {
    try {
      const { id_coach } = req.params;
      const { name_coach, coach_department, years_coach, email, nohp, status_coach } = req.body;
      
      const query = `
        UPDATE coach 
        SET 
          name_coach = ?, 
          coach_department = ?, 
          years_coach = ?, 
          email = ?, 
          nohp = ?, 
          status_coach = ? 
        WHERE id_coach = ?`;
      
      db.query(
        query,
        [name_coach, coach_department, years_coach, email, nohp, status_coach, id_coach],
        (err, results) => {
          if (err) {
            return res.status(500).json({ message: "Error saat memperbarui data pelatih", error: err });
          }
          if (results.affectedRows === 0) {
            return res.status(404).json({ message: "Data pelatih tidak ditemukan" });
          }
          res.json({ 
            message: "Data pelatih berhasil diperbarui",
            data: {
              id_coach,
              name_coach,
              coach_department,
              years_coach,
              email,
              nohp,
              status_coach
            }
          });
        }
      );
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

}

module.exports = coachController; 