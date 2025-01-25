const db = require('../config/database');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

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

// Konfigurasi multer untuk foto pelatih
const coachPhotoStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = 'uploads/coach';
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'coach-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const uploadCoachPhoto = multer({ 
  storage: coachPhotoStorage,
  fileFilter: (req, file, cb) => {
    // Daftar mime type yang diperbolehkan
    const allowedMimes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/gif'
    ];

    if (!file) {
      // Jika tidak ada file, tetap izinkan request
      return cb(null, true);
    }

    if (allowedMimes.includes(file.mimetype)) {
      // File adalah gambar yang valid
      return cb(null, true);
    }

    // File bukan gambar yang valid
    cb(new Error('Hanya file gambar (JPG, JPEG, PNG, GIF) yang diperbolehkan!'));
  },
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB
  }
});

// Tambahkan error handling middleware
const handleUpload = (req, res, next) => {
  const upload = uploadCoachPhoto.single('photo');

  upload(req, res, function(err) {
    if (err instanceof multer.MulterError) {
      // Error dari Multer
      return res.status(400).json({
        message: "Error saat upload file",
        error: err.message
      });
    } else if (err) {
      // Error lainnya
      return res.status(400).json({
        message: err.message || "Error saat upload file"
      });
    }
    // Tidak ada error
    next();
  });
};

// Tambahkan konfigurasi multer untuk management
const managementPhotoStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = 'uploads/management';
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'management-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const uploadManagementPhoto = multer({ 
  storage: managementPhotoStorage,
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'];
    if (!file) return cb(null, true);
    if (allowedMimes.includes(file.mimetype)) {
      return cb(null, true);
    }
    cb(new Error('Hanya file gambar (JPG, JPEG, PNG, GIF) yang diperbolehkan!'));
  },
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

const managementController = {
  
  
  
  //Tabel Students
  register_student: upload.single('photo'),
  async register_student_handler(req, res) {
    console.log('Request body:', req.body);
    try {
      const { id_student, name, date_birth, gender, photo, email, nohp, status } = req.body;
      const registrationDate = new Date();
      
      const photoPath = req.file ? req.file.path : "";
      const query = 'INSERT INTO student (id_student, name, date_birth, gender, photo, email, nohp, registration_date, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
      db.query(query, [id_student, name, date_birth, gender, photoPath, email, nohp, registrationDate, status], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat registrasi", error: err });
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
      const { id_student, name, date_birth, gender, email, nohp, status } = req.body;
      
      // Cek apakah data siswa ada
      const checkQuery = 'SELECT * FROM student WHERE reg_id_student = ?';
      db.query(checkQuery, [reg_id_student], async (checkErr, checkResults) => {
        if (checkErr) {
          return res.status(500).json({ 
            message: "Error saat memeriksa data siswa", 
            error: checkErr 
          });
        }
        
        if (checkResults.length === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }

        // Tentukan path foto
        let photoPath = checkResults[0].photo; // Gunakan foto yang ada
        if (req.file) {
          photoPath = req.file.path;
          
          // Hapus foto lama jika ada
          if (checkResults[0].photo) {
            try {
              fs.unlinkSync(checkResults[0].photo);
            } catch (err) {
              console.error('Error deleting old photo:', err);
            }
          }
        }

        const updateQuery = `
          UPDATE student 
          SET id_student = ?, 
              name = ?, 
              date_birth = ?, 
              gender = ?, 
              email = ?, 
              nohp = ?, 
              status = ?,
              photo = ?
          WHERE reg_id_student = ?`;

        const updateValues = [
          id_student,
          name,
          date_birth,
          gender,
          email,
          nohp,
          status,
          photoPath,
          reg_id_student
        ];

        db.query(updateQuery, updateValues, (err, results) => {
          if (err) {
            return res.status(500).json({ 
              message: "Error saat memperbarui data siswa", 
              error: err 
            });
          }

          res.json({ 
            message: "Data siswa berhasil diperbarui",
            data: {
              reg_id_student,
              id_student,
              name,
              date_birth,
              gender,
              email,
              nohp,
              status,
              photo: photoPath
            }
          });
        });
      });
    } catch (error) {
      res.status(500).json({ 
        message: "Server error", 
        error: error.message || error 
      });
    }
  },
  delete_student: async (req, res) => {
    console.log('Request params:', req.params);
    try {
      const { reg_id_student } = req.params;

      // Cek apakah data siswa ada
      const checkQuery = 'SELECT * FROM student WHERE reg_id_student = ?';
      db.query(checkQuery, [reg_id_student], (checkErr, checkResults) => {
        if (checkErr) {
          return res.status(500).json({ message: "Error saat memeriksa data siswa", error: checkErr });
        }

        if (checkResults.length === 0) {
          return res.status(404).json({ message: "Data siswa tidak ditemukan" });
        }

        // Jika data ditemukan, lakukan delete
        const deleteQuery = 'DELETE FROM student WHERE reg_id_student = ?';
        db.query(deleteQuery, [reg_id_student], (err, results) => {
          if (err) {
            return res.status(500).json({ message: "Error saat menghapus data siswa", error: err });
          }
          res.status(200).json({ 
            message: "Data siswa berhasil dihapus",
            deletedData: checkResults[0]
          });
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  
  // Coach
  register_coach: {
    middleware: handleUpload,
    async handler(req, res) {
      try {
        const { name_coach, coach_department, email, nohp, status_coach, license, experience, achievements, years_coach } = req.body;
        
        // Log untuk debugging
        console.log('Request file:', req.file);
        console.log('Request body:', req.body);
        
        const photoPath = req.file ? req.file.path : null;

        const query = `
          INSERT INTO coach (
            name_coach, coach_department, email, nohp, status_coach, 
            license, experience, achievements, years_coach, photo
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

        db.query(
          query,
          [name_coach, coach_department, email, nohp, status_coach, 
           license, experience, achievements, years_coach, photoPath],
          (err, results) => {
            if (err) {
              console.error('Database error:', err);
              return res.status(500).json({ 
                message: "Error saat registrasi", 
                error: err.message 
              });
            }

            res.status(201).json({
              message: "Registrasi berhasil",
              data: {
                id_coach: results.insertId,
                name_coach,
                coach_department,
                email,
                nohp,
                status_coach,
                license,
                experience,
                achievements,
                years_coach,
                photo: photoPath
              },
            });
          }
        );
      } catch (error) {
        console.error('Server error:', error);
        res.status(500).json({ 
          message: "Server error", 
          error: error.message 
        });
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
      const { name_coach, coach_department, email, nohp, status_coach, license, experience, achievements, years_coach } = req.body;
      
      // Ambil path foto baru jika ada
      const photoPath = req.file ? req.file.path : null;

      // Jika ada foto baru, update foto. Jika tidak, gunakan foto yang lama
      const photoQuery = photoPath ? ', photo = ?' : '';
      const queryParams = [
        name_coach, coach_department, email, nohp, status_coach,
        license, experience, achievements, years_coach
      ];
      if (photoPath) queryParams.push(photoPath);
      queryParams.push(id_coach);

      const query = `
        UPDATE coach 
        SET name_coach = ?, 
            coach_department = ?, 
            email = ?, 
            nohp = ?, 
            status_coach = ?,
            license = ?,
            experience = ?,
            achievements = ?,
            years_coach = ?
            ${photoQuery}
        WHERE id_coach = ?`;
      
      db.query(
        query,
        queryParams,
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
              email,
              nohp,
              status_coach,
              license,
              experience,
              achievements,
              years_coach
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
      const { email, nohp } = req.body;
      
      // Ubah query untuk mengambil semua data management termasuk status
      const query = `SELECT * FROM management WHERE email = ? AND nohp = ?`;

      db.query(query, [email, nohp], async (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat login", error: err });
        }
        
        if (results.length === 0) {
          return res.status(404).json({ message: "Data management tidak ditemukan" });
        }

        const userData = results[0];

        // Cek status user
        if (userData.status !== 1) { // Asumsi 1 = Aktif, 0 = Tidak Aktif
          return res.status(403).json({ 
            message: "Akun Anda tidak aktif. Silakan hubungi administrator.",
            status: "inactive"
          });
        }

        const token = jwt.sign({ 
          id: userData.id_management,
          email: userData.email,
          nohp: userData.nohp,
          status: userData.status
        }, 'kunci_rahasia', { expiresIn: '1h' });
        
        res.json({ 
          message: "Login berhasil",
          token,
          user: userData
        });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },

  //Tambahkan middleware baru untuk mengecek status
  checkActiveStatus: async (req, res, next) => {
    try {
      const token = req.headers.authorization?.split(' ')[1];
      if (!token) {
        return res.status(401).json({ message: "Token tidak ditemukan" });
      }

      const decoded = jwt.verify(token, 'kunci_rahasia');
      if (decoded.status !== 1) {
        return res.status(403).json({ 
          message: "Akun Anda tidak aktif. Silakan hubungi administrator.",
          status: "inactive"
        });
      }
      next();
    } catch (error) {
      res.status(401).json({ message: "Token tidak valid" });
    }
  },

  //Management (Belum Beres)
  async register_management(req, res) {
    try {
      const { name, gender, date_birth, email, nohp, departement, status } = req.body;
      const photoPath = req.file ? req.file.path : null;
      
      const query = 'INSERT INTO management (name, gender, date_birth, email, nohp, departement, status, photo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
      db.query(query, [name, gender, date_birth, email, nohp, departement, status, photoPath], (err, results) => {
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
      const { name, gender, date_birth, email, nohp, departement, status } = req.body;
      
      // Cek apakah data management ada
      const checkQuery = 'SELECT * FROM management WHERE id_management = ?';
      db.query(checkQuery, [id_management], async (checkErr, checkResults) => {
        if (checkErr) {
          return res.status(500).json({ 
            message: "Error saat memeriksa data management", 
            error: checkErr 
          });
        }
        
        if (checkResults.length === 0) {
          return res.status(404).json({ message: "Data management tidak ditemukan" });
        }

        // Tentukan path foto
        let photoPath = checkResults[0].photo; // Gunakan foto yang ada
        if (req.file) {
          photoPath = req.file.path;
          
          // Hapus foto lama jika ada
          if (checkResults[0].photo) {
            try {
              fs.unlinkSync(checkResults[0].photo);
            } catch (err) {
              console.error('Error deleting old photo:', err);
            }
          }
        }

        const updateQuery = `
          UPDATE management 
          SET name = ?, 
              gender = ?, 
              date_birth = ?, 
              email = ?, 
              nohp = ?, 
              departement = ?, 
              status = ?,
              photo = ?
          WHERE id_management = ?`;

        const updateValues = [
          name,
          gender,
          date_birth,
          email,
          nohp,
          departement,
          status,
          photoPath,
          id_management
        ];

        db.query(updateQuery, updateValues, (err, results) => {
          if (err) {
            return res.status(500).json({ 
              message: "Error saat memperbarui data management", 
              error: err 
            });
          }

          res.json({ 
            message: "Data management berhasil diperbarui",
            data: {
              id_management,
              name,
              gender,
              date_birth,
              email,
              nohp,
              departement,
              status,
              photo: photoPath
            }
          });
        });
      });
    } catch (error) {
      res.status(500).json({ 
        message: "Server error", 
        error: error.message || error 
      });
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
      const { name_schedule, date_schedule, waktu_bermain, nama_lapangan, nama_pertandingan } = req.body;
  
      // Validasi input
      if (!name_schedule || !date_schedule || !waktu_bermain || !nama_lapangan || !nama_pertandingan) {
        return res.status(400).json({
          message: "Semua data harus diisi: name_schedule, date_schedule, waktu_bermain, nama_lapangan, nama_pertandingan"
        });
      }
  
      // Query untuk memasukkan data ke tabel schedule
      const query = `
        INSERT INTO schedule (name_schedule, date_schedule, waktu_bermain, nama_lapangan, nama_pertandingan) 
        VALUES (?, ?, ?, ?, ?)
      `;
      
      // Eksekusi query
      db.query(query, [name_schedule, date_schedule, waktu_bermain, nama_lapangan, nama_pertandingan], (err, results) => {
        if (err) {
          console.error(err); // Log error untuk debugging
          return res.status(500).json({
            message: "Error saat membuat jadwal",
            error: err
          });
        }
  
        // Respons berhasil
        res.status(201).json({
          message: "Jadwal berhasil dibuat",
          data: {
            id_schedule: results.insertId,
            name_schedule,
            date_schedule,
            waktu_bermain,
            nama_lapangan,
            nama_pertandingan
          }
        });
      });
    } catch (error) {
      // Error handling jika terjadi kesalahan tak terduga
      console.error(error); // Log error untuk debugging
      res.status(500).json({
        message: "Server error",
        error: error.message || error
      });
    }
  },
  
  read_schedule: async (req, res) => {
    try {
      const query = `
        SELECT 
          id_schedule,
          name_schedule,
          DATE_FORMAT(date_schedule, '%Y-%m-%d') as date_schedule,
          waktu_bermain,
          nama_lapangan,
          nama_pertandingan
        FROM schedule
        ORDER BY date_schedule ASC`;
      db.query(query, (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat mengambil data jadwal", error: err });
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
      const { name_schedule, date_schedule, waktu_bermain, nama_lapangan, nama_pertandingan } = req.body;

      // Validasi input
      if (!name_schedule || !date_schedule || !waktu_bermain || !nama_lapangan || !nama_pertandingan) {
        return res.status(400).json({
          message: "Semua data harus diisi: name_schedule, date_schedule, waktu_bermain, nama_lapangan, nama_pertandingan"
        });
      }

      const query = 'UPDATE schedule SET name_schedule = ?, date_schedule = ?, waktu_bermain = ?, nama_lapangan = ?, nama_pertandingan = ? WHERE id_schedule = ?';
      db.query(query, [name_schedule, date_schedule, waktu_bermain, nama_lapangan, nama_pertandingan, id_schedule], (err, results) => {
        if (err) {
          return res.status(500).json({ message: "Error saat memperbarui data jadwal", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data jadwal tidak ditemukan" });
        }
        res.json({ 
          message: "Data jadwal berhasil diperbarui",
          data: { id_schedule, name_schedule, date_schedule, waktu_bermain, nama_lapangan, nama_pertandingan }
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
          return res.status(500).json({ message: "Error saat menghapus data jadwal", error: err });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Data jadwal tidak ditemukan" });
        }
        res.json({ message: "Data jadwal berhasil dihapus" });
      });
    } catch (error) {
      res.status(500).json({ message: "Server error", error: error });
    }
  },
};

module.exports = managementController; 