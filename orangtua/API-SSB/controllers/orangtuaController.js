const db = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');

const orangtuaController = {
  // untuk login
  login: async (req, res) => {
    try {
      const { email, date_birth } = req.body;

      if (!email || !date_birth) {
        return res.status(400).json({ message: "Email dan tanggal lahir harus diisi" });
      }

      const query = 'SELECT * FROM student WHERE email = ? AND date_birth = ?';
      db.query(query, [email, date_birth], (err, results) => {
        if (err) {
          console.error('Database error:', err);
          return res.status(500).json({ message: "Kesalahan saat login", error: err });
        }

        if (results.length === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }

        const user = results[0];
        const token = jwt.sign(
          {
            id_student: user.id_student,
            email: user.email,
            reg_id_student: user.reg_id_student,
          },
          'kunci_rahasia',
          { expiresIn: '1h' }
        );

        res.status(200).json({
          success: true,
          message: "Login berhasil",
          token,
          user: {
            id_student: user.id_student,
            email: user.email,
            reg_id_student: user.reg_id_student,
            date_birth: user.date_birth,
            status: user.status,
            photo: user.photo,
            nohp: user.nohp,
            registration_date: user.registration_date,
          },
        });
      });
    } catch (error) {
      console.error('Server error:', error);
      res.status(500).json({ message: "Kesalahan server", error });
    }
  },
  get_data_orangtua: async (req, res) => {
    try {
      const { reg_id_student } = req.body;
  
      if (!reg_id_student) {
        return res.status(400).json({ message: "reg_id_student harus diisi" });
      }
  
      const query = 'SELECT * FROM student WHERE reg_id_student = ?';
      db.query(query, [reg_id_student], (err, results) => {
        if (err) {
          console.error('Database error:', err);
          return res.status(500).json({ message: "Kesalahan saat mengambil data", error: err });
        }
  
        if (results.length === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }
  
        const user = results[0];
        res.status(200).json({
          success: true,
          message: "Data berhasil ditemukan",
          user: {
            id_student: user.id_student,
            name: user.name,
            email: user.email,
            reg_id_student: user.reg_id_student,
            date_birth: user.date_birth,
            status: user.status,
            photo: user.photo,
            nohp: user.nohp,
            registration_date: user.registration_date,
          },
        });
      });
    } catch (error) {
      console.error('Server error:', error);
      res.status(500).json({ message: "Kesalahan server", error });
    }
  },

  read_assessment: async (req, res) => {
    try {
      const { reg_id_student } = req.body;

      if (!reg_id_student) {
        return res.status(400).json({ message: "reg_id_student harus diisi" });
      }

      const query = 'SELECT * FROM assessment WHERE reg_id_student = ?';
      db.query(query, [reg_id_student], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data assessment", error: err });
        }

        if (results.length === 0) {
          return res.status(404).json({ message: "Data assessment tidak ditemukan" });
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
      const { name, date_birth, email, nohp, photo } = req.body;
      let photoPath = null;

      // Handle photo upload
      if (photo && photo.startsWith('data:image')) {
        // Hapus foto lama jika ada
        const queryOldPhoto = 'SELECT photo FROM student WHERE reg_id_student = ?';
        db.query(queryOldPhoto, [reg_id_student], (err, results) => {
          if (!err && results[0]?.photo) {
            const oldPhotoPath = path.join(__dirname, '..', results[0].photo);
            if (fs.existsSync(oldPhotoPath)) {
              fs.unlinkSync(oldPhotoPath);
            }
          }
        });

        // Proses foto baru
        const base64Data = photo.replace(/^data:image\/\w+;base64,/, '');
        const fileType = photo.split(';')[0].split('/')[1];
        const fileName = `student_${reg_id_student}_${Date.now()}.${fileType}`;
        photoPath = `uploads/student/${fileName}`;

        // Buat direktori jika belum ada
        const uploadDir = path.join(__dirname, '..', 'uploads', 'student');
        if (!fs.existsSync(uploadDir)) {
          fs.mkdirSync(uploadDir, { recursive: true });
        }

        // Simpan file baru
        fs.writeFileSync(path.join(__dirname, '..', photoPath), base64Data, 'base64');
      }

      // Update database
      const query = `
        UPDATE student 
        SET 
          name = ?,
          date_birth = ?,
          email = ?,
          nohp = ?
          ${photoPath ? ', photo = ?' : ''}
        WHERE reg_id_student = ?`;

      const values = photoPath 
        ? [name, date_birth, email, nohp, photoPath, reg_id_student]
        : [name, date_birth, email, nohp, reg_id_student];

      db.query(query, values, (err, results) => {
        if (err) {
          console.error('Database error:', err);
          return res.status(500).json({ 
            message: "Error saat memperbarui data siswa", 
            error: err 
          });
        }

        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }

        res.status(200).json({ 
          message: "Data siswa berhasil diperbarui",
          data: {
            reg_id_student,
            name,
            date_birth,
            email,
            nohp,
            photo: photoPath
          }
        });
      });
    } catch (error) {
      console.error('Server error:', error);
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  get_profile: async (req, res) => {
    try {
      const token = req.headers.authorization;
      if (!token) {
        return res.status(401).json({ message: "Token tidak ditemukan" });
      }

      const decoded = jwt.verify(token, 'kunci_rahasia');
      const reg_id_student = decoded.reg_id_student;

      const query = 'SELECT * FROM student WHERE reg_id_student = ?';
      db.query(query, [reg_id_student], (err, results) => {
        if (err) {
          console.error('Database error:', err);
          return res.status(500).json({ message: "Kesalahan saat mengambil data", error: err });
        }

        if (results.length === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }

        const user = results[0];
        res.status(200).json({
          success: true,
          message: "Data profil berhasil ditemukan",
          user: {
            id_student: user.id_student,
            name: user.name,
            email: user.email,
            reg_id_student: user.reg_id_student,
            date_birth: user.date_birth,
            status: user.status,
            photo: user.photo,
            nohp: user.nohp,
            registration_date: user.registration_date,
          },
        });
      });
    } catch (error) {
      console.error('Server error:', error);
      res.status(500).json({ message: "Kesalahan server", error });
    }
  },

};

module.exports = orangtuaController; 