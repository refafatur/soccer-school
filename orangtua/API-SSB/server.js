const express = require('express');
const cors = require('cors');
const app = express();
const managementController = require('./controllers/managementController');
const orangtuaController = require('./controllers/orangtuaController');
const coachController = require('./controllers/coachController');
const { verifyToken } = require('./middleware/authMiddleware');
const path = require('path');

// Middleware
app.use(express.json({limit: '10mb'}));
app.use(express.urlencoded({limit: '10mb', extended: true}));
app.use(cors());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Manajemen
app.post('/api/register_student', 
  managementController.register_student_handler
);
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
app.get('/api/aspect', managementController.read_aspect);
app.put('/api/aspect/:id_aspect', managementController.update_aspect);
app.delete('/api/aspect/:id_aspect', managementController.delete_aspect);

// Aspect_Sub
app.post('/api/aspect_sub', managementController.create_aspect_sub);
app.get('/api/aspect_sub', managementController.read_aspect_sub);
app.put('/api/aspect_sub/:id_aspect_sub', managementController.update_aspect_sub);
app.delete('/api/aspect_sub/:id_aspect_sub', managementController.delete_aspect_sub);

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


//################################


// Orang Tua
app.post('/api/orangtua/login', orangtuaController.login);
app.post('/api/orangtua/get_data_orangtua', orangtuaController.get_data_orangtua);
app.post('/api/orangtua/assessment', orangtuaController.read_assessment);
app.get('/api/orangtua/assessment_setting', orangtuaController.read_assessment_setting);
app.get('/api/orangtua/information', orangtuaController.read_information);
app.get('/api/orangtua/schedule', orangtuaController.read_schedule);
app.put('/api/orangtua/profile/:reg_id_student', orangtuaController.update_student);
app.get('/api/orangtua/profile', orangtuaController.get_profile);
// app.post('/api/orangtua/schedule_today', orangtuaController.get_schedule_today);



//################################


//Coach
app.post('/api/coach/login', coachController.login);
app.get('/api/coach/aspect', coachController.read_aspect);
app.get('/api/coach/aspect_sub', coachController.read_aspect_sub);
//Assesment
app.post('/api/coach/assessment', coachController.create_assessment);
app.get('/api/coach/assessment', coachController.read_assessment);
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
app.put('/api/coach/:id_coach', managementController.update_coach);





// Protected Route contoh
app.get('/protected', verifyToken, (req, res) => {
  res.json({ message: "Ini adalah route yang dilindungi" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
});