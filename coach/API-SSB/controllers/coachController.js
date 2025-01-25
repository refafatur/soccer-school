const db = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const coachController = {
  //Login Coach
  login: async (req, res) => {
    try {
      const { email, nohp } = req.body;
      
      // Tambahkan log untuk debugging
      console.log('Login attempt:', { email, nohp });
      
      const query = 'SELECT * FROM coach WHERE email = ? AND nohp = ?';
      db.query(query, [email, nohp], async (err, results) => {
        if (err) {
          console.error('Database error:', err);
          return res.status(500).json({ 
            message: "Error saat login", 
            error: err.message 
          });
        }
        
        if (results.length === 0) {
          return res.status(401).json({ 
            message: "Email atau nomor HP tidak valid" 
          });
        }

        const coach = results[0];
        const token = jwt.sign({ 
          id_coach: coach.id_coach,
          name_coach: coach.name_coach,
          coach_department: coach.coach_department,
          years_coach: coach.years_coach,
          email: coach.email,
          nohp: coach.nohp,
          status_coach: coach.status_coach,
          license: coach.license,
          experience: coach.experience,
          achievements: coach.achievements,
          photo: coach.photo
        }, 'kunci_rahasia', { expiresIn: '24h' });
        
        res.json({ 
          message: "Login berhasil",
          token,
          data: {
            id_coach: coach.id_coach,
            name_coach: coach.name_coach,
            coach_department: coach.coach_department,
            years_coach: coach.years_coach,
            email: coach.email,
            nohp: coach.nohp,
            status_coach: coach.status_coach,
            license: coach.license,
            experience: coach.experience,
            achievements: coach.achievements,
            photo: coach.photo
          }
        });
      });
    } catch (error) {
      console.error('Server error:', error);
      res.status(500).json({ 
        message: "Server error", 
        error: error.message 
      });
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

  //Konfigurasi multer untuk upload foto
  storage: multer.diskStorage({
    destination: function (req, file, cb) {
      cb(null, 'uploads/coach')
    },
    filename: function (req, file, cb) {
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)
      cb(null, 'coach-' + uniqueSuffix + path.extname(file.originalname))
    }
  }),

  upload: multer({ 
    storage: multer.diskStorage({
      destination: function (req, file, cb) {
        cb(null, 'uploads/coach')
      },
      filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)
        cb(null, 'coach-' + uniqueSuffix + path.extname(file.originalname))
      }
    }),
    fileFilter: (req, file, cb) => {
      // Terima file dari web
      if (file.mimetype.startsWith('image/')) {
        cb(null, true)
      } else {
        cb(new Error('Hanya file gambar yang diperbolehkan'));
      }
    },
    limits: {
      fileSize: 5 * 1024 * 1024 // 5MB limit
    }
  }).single('photo'),

  //Update fungsi update_coach
  update_coach: async (req, res) => {
    try {
      const { id_coach } = req.params;
      let photoPath = null;

      // Tambahkan logging
      console.log('File yang diterima:', req.file);
      
      if (req.file) {
        photoPath = `/uploads/coach/${req.file.filename}`;
        console.log('Photo path:', photoPath);
      }

      // Ambil data dari request body
      const { 
        name_coach, 
        coach_department, 
        years_coach, 
        email, 
        nohp, 
        status_coach,
        license,
        experience,
        achievements
      } = req.body;

      // Buat query update
      const query = `
        UPDATE coach 
        SET 
          name_coach = ?, 
          coach_department = ?, 
          years_coach = ?, 
          email = ?, 
          nohp = ?, 
          status_coach = ?,
          license = ?,
          experience = ?,
          achievements = ?
          ${photoPath ? ', photo = ?' : ''}
        WHERE id_coach = ?
      `;

      const values = [
        name_coach, 
        coach_department, 
        years_coach, 
        email, 
        nohp, 
        status_coach,
        license,
        experience,
        achievements,
        ...(photoPath ? [photoPath] : []),
        id_coach
      ];

      db.query(query, values, (err, results) => {
        if (err) {
          console.error('Error updating coach:', err);
          return res.status(500).json({ 
            message: "Error saat memperbarui data pelatih", 
            error: err.message 
          });
        }

        // Fetch dan return data yang diperbarui
        db.query('SELECT * FROM coach WHERE id_coach = ?', [id_coach], (err, results) => {
          if (err) {
            return res.status(500).json({ 
              message: "Error saat mengambil data pelatih yang diperbarui", 
              error: err.message 
            });
          }

          res.json({ 
            message: "Data pelatih berhasil diperbarui",
            data: results[0]
          });
        });
      });
    } catch (error) {
      console.error('Server error:', error);
      res.status(500).json({ 
        message: "Server error", 
        error: error.message 
      });
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

  getAllCoaches: async (req, res) => {
    try {
      const query = `
        SELECT 
          id_coach,
          name_coach,
          coach_department,
          years_coach,
          email,
          nohp,
          status_coach
        FROM coach
        ORDER BY name_coach ASC`;
      
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ 
            message: "Error saat mengambil data coach", 
            error: err 
          });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ 
        message: "Server error", 
        error: error 
      });
    }
  },

}

module.exports = coachController;