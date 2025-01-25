const express = require('express');
const cors = require('cors');
const app = express();
const managementController = require('./controllers/managementController');
const orangtuaController = require('./controllers/orangtuaController');
const coachController = require('./controllers/coachController');
const { verifyToken } = require('./middleware/authMiddleware');
const path = require('path');
const fs = require('fs');
const pool = require('./db/db');
const jwt = require('jsonwebtoken');
const { secret } = require('./config/jwt.config');

// Tambahkan ini di awal file setelah imports
const uploadDir = path.join(__dirname, 'uploads/coach');
if (!fs.existsSync(uploadDir)){
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Manajemen
app.post('/api/register_student', 
  managementController.register_student,
  managementController.register_student_handler);
app.get('/api/register_student', managementController.get_student);
app.put('/api/register_student/:reg_id_student', managementController.update_student);
app.delete('/api/register_student/:reg_id_student', managementController.delete_student);

// Coach yang di Manager
app.post('/api/register_coach', 
  managementController.register_coach.handler
);
app.get('/api/register_coach', managementController.get_coach);
app.put('/api/register_coach/:id_coach', managementController.update_coach);
app.delete('/api/register_coach/:id_coach', managementController.delete_coach);


// Management yang ada di management (Belum Beres)
app.post('/api/register_management', managementController.register_management);
app.get('/api/register_management', managementController.get_management);
app.put('/api/register_management/:id_management', managementController.update_management);
app.delete('/api/register_management/:id_management', managementController.delete_management);

//Aspect
app.post('/api/aspect', managementController.create_aspect);
app.get('/api/aspect', verifyToken, async (req, res) => {
  try {
    const query = 'SELECT * FROM aspect';
    const [aspects] = await pool.execute(query);
    
    res.json({
      status: 'success',
      data: aspects
    });
  } catch (error) {
    console.error('Error getting aspects:', error);
    res.status(500).json({
      status: 'error',
      message: 'Gagal mengambil data aspect'
    });
  }
});

// Aspect_Sub
app.post('/api/aspect_sub', managementController.create_aspect_sub);
app.get('/api/aspect_sub', async (req, res) => {
  try {
    console.log('Fetching aspect_sub data...');
    const query = `
      SELECT 
        asp.id_aspect_sub,
        asp.name_aspect_sub,
        asp.ket_aspect_sub,
        asp.id_aspect,
        a.name_aspect
      FROM aspect_sub asp
      LEFT JOIN aspect a ON asp.id_aspect = a.id_aspect
      ORDER BY asp.id_aspect_sub ASC
    `;
    
    const [aspectSubs] = await pool.execute(query);
    console.log('AspectSub data:', aspectSubs);
    
    res.json({
      status: 'success',
      data: aspectSubs
    });
  } catch (error) {
    console.error('Error fetching aspect_sub:', error);
    res.status(500).json({
      status: 'error',
      message: 'Gagal mengambil data aspect sub'
    });
  }
});

//Assesment
app.post('/api/assessment', managementController.create_assessment);
app.get('/api/assessment', managementController.read_assessment);
app.put('/api/assessment/:id_assessment', managementController.update_assessment);
app.delete('/api/assessment/:id_assessment', managementController.delete_assessment);

//Assessment Setting
app.post('/api/assessment_setting', managementController.create_assessment_setting);
app.get('/api/assessment_setting', managementController.read_assessment_setting);
app.put('/api/assessment_setting/:id_assessment_setting', managementController.update_assessment_setting);
app.delete('/api/assessment_setting/:id_assessment_setting', managementController.delete_assessment_setting);

// Schedule
app.post('/api/schedule', managementController.create_schedule);
app.get('/api/schedule', managementController.read_schedule);
app.put('/api/schedule/:id_schedule', managementController.update_schedule);
app.delete('/api/schedule/:id_schedule', managementController.delete_schedule);

// Department
app.post('/api/department', managementController.create_department);
app.get('/api/department', managementController.read_department);
app.put('/api/department/:id_department', managementController.update_department);
app.delete('/api/department/:id_department', managementController.delete_department);

// Information
app.post('/api/information', managementController.create_information);
app.get('/api/information', managementController.read_information);
app.put('/api/information/:id_information', managementController.update_information);
app.delete('/api/information/:id_information', managementController.delete_information);

//Point Rate
app.post('/api/point_rate', managementController.create_point_rate);
app.get('/api/point_rate', managementController.read_point_rate);
app.put('/api/point_rate/:id_point_rate', managementController.update_point_rate);
app.delete('/api/point_rate/:id_point_rate', managementController.delete_point_rate);


//Login management
app.post('/api/management/login', managementController.login);


// Orang Tua
app.post('/api/orangtua/login', orangtuaController.login);
app.get('/api/orangtua/assessment', orangtuaController.read_assessment);
app.get('/api/orangtua/assessment_setting', orangtuaController.read_assessment_setting);
app.get('/api/orangtua/information', orangtuaController.read_information);
app.get('/api/orangtua/schedule', orangtuaController.read_schedule);
app.put('/api/orangtua/profile/:reg_id_student', orangtuaController.update_student);

//Coach
app.post('/api/coach/login', async (req, res) => {
  try {
    console.log('=== LOGIN REQUEST ===');
    const { email, nohp } = req.body;
    console.log('Request body:', req.body);
    console.log('Email:', email);
    console.log('NoHP:', nohp);

    if (!email || !nohp) {
      console.log('Missing credentials');
      return res.status(400).json({
        status: 'error',
        message: 'Email dan nomor HP harus diisi'
      });
    }

    const query = 'SELECT * FROM coach WHERE email = ? AND nohp = ?';
    console.log('Executing query:', query);
    console.log('Query params:', [email, nohp]);
    
    const [coaches] = await pool.execute(query, [email, nohp]);
    console.log('Query result:', coaches);

    if (coaches.length === 0) {
      console.log('No coach found');
      return res.status(401).json({
        status: 'error',
        message: 'Email atau nomor HP tidak valid'
      });
    }

    const coach = coaches[0];
    console.log('Coach found:', coach);
    
    const token = jwt.sign(
      { 
        id_coach: coach.id_coach,
        email: coach.email 
      }, 
      secret,
      { expiresIn: '24h' }
    );
    console.log('Token generated:', token);

    const response = {
      status: 'success',
      message: 'Login berhasil',
      token: token,
      data: {
        id_coach: coach.id_coach,
        name_coach: coach.name_coach,
        email: coach.email
      }
    };
    
    console.log('Sending response:', response);
    res.json(response);

  } catch (error) {
    console.error('=== LOGIN ERROR ===');
    console.error('Error details:', error);
    res.status(500).json({
      status: 'error',
      message: 'Gagal melakukan login: ' + error.message
    });
  }
});
app.get('/api/coach/aspect', coachController.read_aspect);
app.get('/api/coach/aspect_sub', coachController.read_aspect_sub);
//Assesment
app.post('/api/coach/assessment', coachController.create_assessment);
app.get('/api/coach/assessment', async (req, res) => {
  try {
    console.log('Fetching assessments...');
    const query = `
      SELECT 
        a.id_assessment,
        a.year_academic,
        a.year_assessment,
        a.reg_id_student,
        a.id_aspect_sub,
        a.id_coach,
        a.point,
        a.ket,
        a.date_assessment,
        s.name AS student_name,
        asp.name_aspect_sub,
        asp.ket_aspect_sub,
        asp.id_aspect
      FROM assessment a
      LEFT JOIN student s 
        ON a.reg_id_student = s.reg_id_student
      LEFT JOIN aspect_sub asp 
        ON a.id_aspect_sub = asp.id_aspect_sub
    `;
    
    const [assessments] = await pool.execute(query);
    console.log('Query result:', assessments);
    
    // Ambil data student dan aspect_sub terlebih dahulu
    const studentQuery = 'SELECT reg_id_student, name FROM student';
    const aspectSubQuery = 'SELECT id_aspect_sub, name_aspect_sub, ket_aspect_sub, id_aspect FROM aspect_sub';
    
    const [students] = await pool.execute(studentQuery);
    const [aspectSubs] = await pool.execute(aspectSubQuery);
    
    // Buat map untuk mempermudah lookup
    const studentMap = new Map(students.map(s => [s.reg_id_student, s]));
    const aspectSubMap = new Map(aspectSubs.map(a => [a.id_aspect_sub, a]));
    
    const transformedData = assessments.map(assessment => ({
      id_assessment: parseInt(assessment.id_assessment), // Pastikan integer
      year_academic: assessment.year_academic,           // Biarkan string jika tahun
      year_assessment: assessment.year_assessment,       // Biarkan string jika tahun
      reg_id_student: parseInt(assessment.reg_id_student),
      id_aspect_sub: parseInt(assessment.id_aspect_sub),
      id_coach: parseInt(assessment.id_coach),
      point: parseInt(assessment.point),
      ket: assessment.ket || '',
      date_assessment: assessment.date_assessment,
      student_name: assessment.student_name || 'Tidak tersedia',
      name_aspect_sub: assessment.name_aspect_sub || 'Tidak tersedia',
      ket_aspect_sub: assessment.ket_aspect_sub || '',
      id_aspect: parseInt(assessment.id_aspect) || 0
    }));
    

    console.log('Transformed data:', transformedData);
    res.json(transformedData);
  } catch (error) {
    console.error('Error in /coach/assessment:', error);
    res.status(500).json({
      status: 'error',
      message: 'Gagal mengambil data assessment: ' + error.message
    });
  }
});
app.put('/api/coach/assessment/:id_assessment', coachController.update_assessment);
app.delete('/api/coach/assessment/:id_assessment', coachController.delete_assessment);
//Assessment Setting
app.post('/api/coach/assessment_setting', coachController.create_assessment_setting);
app.get('/api/coach/assessment_setting', coachController.read_assessment_setting);
app.put('/api/coach/assessment_setting/:id_assessment_setting', coachController.update_assessment_setting);
app.delete('/api/coach/assessment_setting/:id_assessment_setting', coachController.delete_assessment_setting);

app.get('/api/coach/information', coachController.read_information);
app.get('/api/coach/schedule', coachController.read_schedule);
app.get('/api/coach/point_rate', coachController.read_point_rate);
app.put('/api/coach/:id_coach', coachController.upload, coachController.update_coach);
app.get('/api/coach/coaches', coachController.getAllCoaches);

// Tambahkan endpoint untuk profile coach
app.get('/api/coach/profile', verifyToken, async (req, res) => {
  try {
    // Ambil id_coach dari token yang sudah diverifikasi
    const idCoach = req.user.id_coach;
    
    console.log('Accessing profile with id_coach:', idCoach); // Debug log
    
    // Query untuk mengambil data coach
    const query = `
      SELECT 
        id_coach,
        name_coach,
        coach_department,
        years_coach,
        email,
        nohp,
        status_coach,
        license,
        experience,
        achievements,
        photo
      FROM coach 
      WHERE id_coach = ?
    `;
    
    const [coach] = await pool.execute(query, [idCoach]);
    console.log('Query result:', coach); // Debug log
    
    if (coach.length === 0) {
      return res.status(404).json({ 
        status: 'error',
        message: 'Coach tidak ditemukan' 
      });
    }
    
    res.json({
      status: 'success',
      data: coach[0]
    });
    
  } catch (error) {
    console.error('Error getting coach profile:', error);
    res.status(500).json({ 
      status: 'error',
      message: 'Gagal mengambil data profile coach' 
    });
  }
});





// Protected Route contoh
app.get('/protected', verifyToken, (req, res) => {
  res.json({ message: "Ini adalah route yang dilindungi" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
});