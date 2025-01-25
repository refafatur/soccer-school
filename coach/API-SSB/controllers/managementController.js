const db = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');

// Konfigurasi multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/student'); // Menyimpan di folder uploads/student
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // Menambahkan timestamp ke nama file
  }
});
const upload = multer({ storage: storage });

const managementController = {
  //Tabel Students
  register_student: upload.single('photo'),
  async register_student_handler(req, res) { // Mengubah nama fungsi untuk menghindari error
    console.log('Request body:', req.body); // Tambahkan log ini
    try {
      const { id_student, name, date_birth, gender, photo, email, nohp, status } = req.body;
      const registrationDate = new Date(); // Menggunakan tanggal registrasi yang ditentukan
      
      const photoPath = req.file ? req.file.path : ""; // Mengizinkan photo kosong
      const query = 'INSERT INTO student (id_student, name, date_birth, gender, photo, email, nohp, registration_date, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
      db.query(query, [id_student, name, date_birth, gender, photoPath, email, nohp, registrationDate, status], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat registrasi", error: {
              code: "ER_PARSE_ERROR",
              errno: 1064,
              sqlState: "42000",
              sqlMessage: "You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near '?)' at line 1",
              sql: query
            } });
        }
        res.status(201).json({ message: "Registrasi berhasil" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  get_student: async (req, res) => {
    try {
      const query = 'SELECT * FROM student';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data siswa", error: err });
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
  
  delete_student: async (req, res) => {
    try {
      const { reg_id_student } = req.params;
      const query = 'DELETE FROM student WHERE reg_id_student = ?';
      db.query(query, [reg_id_student], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data siswa", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }
        res.json({ message: "Data siswa berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },
    
  // Coach
register_coach: {
  async handler(req, res) {
    console.log('Request body:', req.body);
    try {
      const { name_coach, coach_department, years_coach, email, nohp, status_coach } = req.body;
      
      // Validasi input
      if (!name_coach || !coach_department || !years_coach || !email || !nohp || !status_coach) {
        return res.status(400).json({ message: "Semua field harus diisi" });
      }
      
      // Query untuk memasukkan data pelatih baru
      const query = 'INSERT INTO coach (name_coach, coach_department, years_coach, email, nohp, status_coach) VALUES (?, ?, ?, ?, ?, ?)';
      db.query(query, [name_coach, coach_department, years_coach, email, nohp, status_coach], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat registrasi", error: err });
        }
        // Mengembalikan respons sukses dengan data pelatih yang baru ditambahkan
        res.status(201).json({ 
          message: "Registrasi berhasil",
          data: {
            id_coach: results.insertId,
            name_coach,
            coach_department,
            years_coach,
            email,
            nohp,
            status_coach
          }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  }
},

  get_coach: async (req, res) => {
    try {
      const query = 'SELECT * FROM coach';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data pelatih", error: err });
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
  
  delete_coach: async (req, res) => {
    try {
      const { id_coach } = req.params;
      const query = 'DELETE FROM coach WHERE id_coach = ?';
      db.query(query, [id_coach], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data pelatih", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data pelatih tidak ditemukan" });
        }
        res.json({ message: "Data pelatih berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  // Management
  login: async (req, res) => {
    try {
      const { email, date_birth } = req.body;
      
      const query = 'SELECT * FROM management WHERE email = ? AND nohp = ?';
      db.query(query, [email, date_birth], async (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat login", error: err });
        }
        
        if (results.length === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }

        const token = jwt.sign({ 
          id: results[0].id_management, // Menggunakan id_management yang benar
          email: results[0].email,
          nohp: results[0].nohp
        }, 'kunci_rahasia', { expiresIn: '1h' });
        
        res.json({ 
          message: "Login berhasil",
          token,
          user: {
            id: results[0].id_management, // Menggunakan id_management yang benar
            email: results[0].email,
            nohp: results[0].nohp
          }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Management (Belum Beres)
  async register_management(req, res) { // Mengubah nama fungsi sesuai instruksi
    console.log('Request body:', req.body); // Tambahkan log ini
    try {
      const { name, gender, date_birth, email, nohp, id_departement, status } = req.body;
      
      const query = 'INSERT INTO management (name, gender, date_birth, email, nohp, id_departement, status) VALUES (?, ?, ?, ?, ?, ?, ?)';
      db.query(query, [name, gender, date_birth, email, nohp, id_departement, status], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat registrasi", error: err });
        }
        res.status(201).json({ message: "Registrasi berhasil" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  get_management: async (req, res) => {
    try {
      const query = 'SELECT * FROM management';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data management", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  update_management: async (req, res) => {
    try {
      const { id_management } = req.params;
      const { name, gender, date_birth, email, nohp, id_departement, status } = req.body;
      
      const query = 'UPDATE management SET name = ?, gender = ?, date_birth = ?, email = ?, nohp = ?, id_departement = ?, status = ? WHERE id_management = ?';
      db.query(query, [name, gender, date_birth, email, nohp, id_departement, status, id_management], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data management", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data management tidak ditemukan" });
        }
        res.json({ 
          message: "Data management berhasil diperbarui",
          data: { id_management, name, gender, date_birth, email, nohp, id_departement, status }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  delete_management: async (req, res) => {
    try {
      const { id_management } = req.params;
      const query = 'DELETE FROM management WHERE id_management = ?';
      db.query(query, [id_management], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data management", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data management tidak ditemukan" });
        }
        res.json({ message: "Data management berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  create_aspect: async (req, res) => {
    try {
      const { name_aspect } = req.body;
      const query = 'INSERT INTO aspect (name_aspect) VALUES (?)';
      db.query(query, [name_aspect], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menambahkan data aspect", error: err });
        }
        res.json({ 
          message: "Data aspect berhasil ditambahkan",
          data: { id_aspect: results.insertId, name_aspect }
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

  update_aspect: async (req, res) => {
    try {
      const { id_aspect } = req.params;
      const { name_aspect } = req.body;
      const query = 'UPDATE aspect SET name_aspect = ? WHERE id_aspect = ?';
      db.query(query, [name_aspect, id_aspect], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data aspect", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data aspect tidak ditemukan" });
        }
        res.json({ 
          message: "Data aspect berhasil diperbarui",
          data: { id_aspect, name_aspect }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  delete_aspect: async (req, res) => {
    try {
      const { id_aspect } = req.params;
      const query = 'DELETE FROM aspect WHERE id_aspect = ?';
      db.query(query, [id_aspect], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data aspect", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data aspect tidak ditemukan" });
        }
        res.json({ message: "Data aspect berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  // Aspect_sub
  create_aspect_sub: async (req, res) => {
    try {
      const { id_aspect, name_aspect_sub, ket_aspect_sub } = req.body;
      const query = 'INSERT INTO aspect_sub (id_aspect, name_aspect_sub, ket_aspect_sub) VALUES (?, ?, ?)';
      db.query(query, [id_aspect, name_aspect_sub, ket_aspect_sub], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat membuat data aspect_sub", error: err });
        }
        res.json({ 
          message: "Data aspect_sub berhasil dibuat",
          data: { id_aspect_sub: results.insertId, id_aspect, name_aspect_sub, ket_aspect_sub }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

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

  update_aspect_sub: async (req, res) => {
    try {
      const { id_aspect_sub } = req.params;
      const { id_aspect, name_aspect_sub, ket_aspect_sub } = req.body;
      const query = 'UPDATE aspect_sub SET id_aspect = ?, name_aspect_sub = ?, ket_aspect_sub = ? WHERE id_aspect_sub = ?';
      db.query(query, [id_aspect, name_aspect_sub, ket_aspect_sub, id_aspect_sub], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data aspect_sub", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data aspect_sub tidak ditemukan" });
        }
        res.json({ 
          message: "Data aspect_sub berhasil diperbarui",
          data: { id_aspect_sub, id_aspect, name_aspect_sub, ket_aspect_sub }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  delete_aspect_sub: async (req, res) => {
    try {
      const { id_aspect_sub } = req.params;
      const query = 'DELETE FROM aspect_sub WHERE id_aspect_sub = ?';
      db.query(query, [id_aspect_sub], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data aspect_sub", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data aspect_sub tidak ditemukan" });
        }
        res.json({ message: "Data aspect_sub berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Assesment
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
  
  //Departemen
  create_department: async (req, res) => {
    try {
      const { name_department, status } = req.body;
      const query = 'INSERT INTO department (name_department, status) VALUES (?, ?)';
      db.query(query, [name_department, status], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat membuat department", error: err });
        }
        res.json({ 
          message: "Department berhasil dibuat",
          data: { id_department: results.insertId, name_department, status }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  read_department: async (req, res) => {
    try {
      const query = 'SELECT * FROM department';
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data department", error: err });
        }
        res.json(results);
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  update_department: async (req, res) => {
    try {
      const { id_department } = req.params;
      const { name_department, status } = req.body;
      const query = 'UPDATE department SET name_department = ?, status = ? WHERE id_department = ?';
      db.query(query, [name_department, status, id_department], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data department", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data department tidak ditemukan" });
        }
        res.json({ 
          message: "Data department berhasil diperbarui",
          data: { id_department, name_department, status }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  delete_department: async (req, res) => {
    try {
      const { id_department } = req.params;
      const query = 'DELETE FROM department WHERE id_department = ?';
      db.query(query, [id_department], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data department", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data department tidak ditemukan" });
        }
        res.json({ message: "Data department berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Information
  create_information: async (req, res) => {
    try {
      const { name_info, info, date_info, status_info } = req.body;
      const query = 'INSERT INTO information (name_info, info, date_info, status_info) VALUES (?, ?, ?, ?)';
      db.query(query, [name_info, info, date_info, status_info], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat membuat data information", error: err });
        }
        res.json({ 
          message: "Data information berhasil dibuat",
          data: { id_information: results.insertId, name_info, info, date_info, status_info }
        });
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

  update_information: async (req, res) => {
    try {
      const { id_information } = req.params;
      const { name_info, info, date_info, status_info } = req.body;
      const query = 'UPDATE information SET name_info = ?, info = ?, date_info = ?, status_info = ? WHERE id_information = ?';
      db.query(query, [name_info, info, date_info, status_info, id_information], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data information", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data information tidak ditemukan" });
        }
        res.json({ 
          message: "Data information berhasil diperbarui",
          data: { id_information, name_info, info, date_info, status_info }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  delete_information: async (req, res) => {
    try {
      const { id_information } = req.params;
      const query = 'DELETE FROM information WHERE id_information = ?';
      db.query(query, [id_information], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data information", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data information tidak ditemukan" });
        }
        res.json({ message: "Data information berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Point_Rate
  create_point_rate: async (req, res) => {
    try {
      const { point_rate, rate } = req.body;
      const query = 'INSERT INTO point_rate (point_rate, rate) VALUES (?, ?)';
      db.query(query, [point_rate, rate], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat membuat data point_rate", error: err });
        }
        res.json({ 
          message: "Data point_rate berhasil dibuat",
          data: { id_point_rate: results.insertId, point_rate, rate }
        });
      });
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

  update_point_rate: async (req, res) => {
    try {
      const { id_point_rate } = req.params;
      const { point_rate, rate } = req.body;
      const query = 'UPDATE point_rate SET point_rate = ?, rate = ? WHERE id_point_rate = ?';
      db.query(query, [point_rate, rate, id_point_rate], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data point_rate", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data point_rate tidak ditemukan" });
        }
        res.json({ 
          message: "Data point_rate berhasil diperbarui",
          data: { id_point_rate, point_rate, rate }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  delete_point_rate: async (req, res) => {
    try {
      const { id_point_rate } = req.params;
      const query = 'DELETE FROM point_rate WHERE id_point_rate = ?';
      db.query(query, [id_point_rate], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data point_rate", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data point_rate tidak ditemukan" });
        }
        res.json({ message: "Data point_rate berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Schedule
  create_schedule: async (req, res) => {
    try {
      const { name_schedule, date_schedule, status_schedule } = req.body;
      const query = 'INSERT INTO schedule (name_schedule, date_schedule, status_schedule) VALUES (?, ?, ?)';
      db.query(query, [name_schedule, date_schedule, status_schedule], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat membuat schedule", error: err });
        }
        res.json({ 
          message: "Schedule berhasil dibuat",
          data: { id_schedule: results.insertId, name_schedule, date_schedule, status_schedule }
        });
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

  update_schedule: async (req, res) => {
    try {
      const { id_schedule } = req.params;
      const { name_schedule, date_schedule, status_schedule } = req.body;
      const query = 'UPDATE schedule SET name_schedule = ?, date_schedule = ?, status_schedule = ? WHERE id_schedule = ?';
      db.query(query, [name_schedule, date_schedule, status_schedule, id_schedule], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data schedule", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data schedule tidak ditemukan" });
        }
        res.json({ 
          message: "Data schedule berhasil diperbarui",
          data: { id_schedule, name_schedule, date_schedule, status_schedule }
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  delete_schedule: async (req, res) => {
    try {
      const { id_schedule } = req.params;
      const query = 'DELETE FROM schedule WHERE id_schedule = ?';
      db.query(query, [id_schedule], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat menghapus data schedule", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data schedule tidak ditemukan" });
        }
        res.json({ message: "Data schedule berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },
};

module.exports = managementController; 