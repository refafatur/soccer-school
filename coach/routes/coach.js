const express = require('express');
const router = express.Router();
const coachController = require('../controllers/coachController');

// Login route
router.post('/login', coachController.login);

// Aspect routes
router.get('/aspect', coachController.read_aspect);
router.get('/aspect_sub', coachController.read_aspect_sub);

// Assessment routes
router.post('/assessment', coachController.create_assessment);
router.get('/assessment', coachController.read_assessment);
router.put('/assessment/:id_assessment', coachController.update_assessment);
router.delete('/assessment/:id_assessment', coachController.delete_assessment);

// Assessment Setting routes
router.post('/assessment_setting', coachController.create_assessment_setting);
router.get('/assessment_setting', coachController.read_assessment_setting);
router.put('/assessment_setting/:id_assessment_setting', coachController.update_assessment_setting);
router.delete('/assessment_setting/:id_assessment_setting', coachController.delete_assessment_setting);

// Information, Schedule, and Point Rate routes
router.get('/information', coachController.read_information);
router.get('/schedule', coachController.read_schedule);
router.get('/point_rate', coachController.read_point_rate);

// Coach update route
router.put('/:id_coach', coachController.update_coach);

module.exports = router; 