const express = require('express');
const router = express.Router();
const curriculumController = require('../controllers/curriculumController');
const authMiddleware = require('../middleware/authMiddleware');

// Ruta para crear un currículum
router.post('/create', authMiddleware, curriculumController.uploadMiddleware, curriculumController.uploadCurriculum);

// Ruta para obtener todos los currículums
router.get('/', curriculumController.getCurriculums);

// Ruta para descargar un currículum por ID
router.get('/:id/download', authMiddleware, curriculumController.downloadCurriculum);

module.exports = router;
