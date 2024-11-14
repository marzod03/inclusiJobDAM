const pool = require('../config/db');
const fs = require('fs');
const multer = require('multer');

// Configura multer para manejar la subida de archivos
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); 
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname); 
  },
});

const upload = multer({ storage: storage });

// Middleware para manejar la subida de un solo archivo
exports.uploadMiddleware = upload.single('archivo');

// Método para subir el currículum
exports.uploadCurriculum = async (req, res) => {
  try {
    const usuarioId = req.user.userId;
    const { file } = req;

    if (!file) {
      return res.status(400).json({ error: 'No se ha proporcionado un archivo' });
    }

    const nombreArchivo = file.originalname;
    const archivo = fs.readFileSync(file.path);

    await pool.query(
      'INSERT INTO curriculums (usuario_id, nombre_archivo, archivo, fecha_subida) VALUES ($1, $2, $3, NOW())',
      [usuarioId, nombreArchivo, archivo]
    );

    // Elimina el archivo temporal después de leerlo
    fs.unlinkSync(file.path);

    res.status(201).json({ message: 'Currículum guardado exitosamente' });
  } catch (error) {
    console.error('Error al guardar el currículum:', error); 
    res.status(500).json({ error: 'Error al guardar el currículum' });
  }
};

// Método para obtener la lista de currículums
exports.getCurriculums = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, usuario_id, nombre_archivo FROM curriculums'
    );

    // Devuelve solo los datos básicos para la lista, sin el archivo binario
    const curriculums = result.rows.map(row => ({
      id: row.id,
      usuario_id: row.usuario_id,
      nombre_archivo: row.nombre_archivo,
    }));

    res.json(curriculums);
  } catch (error) {
    console.error('Error al obtener los currículums:', error);
    res.status(500).json({ error: 'Error al obtener los currículums' });
  }
};

// Método adicional para descargar el archivo PDF
exports.downloadCurriculum = async (req, res) => {
  try {
    const { id } = req.params;

    // Consulta la base de datos para obtener el archivo y el nombre
    const result = await pool.query('SELECT archivo, nombre_archivo FROM curriculums WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Currículum no encontrado' });
    }

    const archivo = result.rows[0].archivo;
    const nombreArchivo = result.rows[0].nombre_archivo;

    // Envía el archivo como respuesta para la descarga
    res.setHeader('Content-Disposition', `attachment; filename="${nombreArchivo}"`);
    res.setHeader('Content-Type', 'application/pdf');
    res.send(archivo);

  } catch (error) {
    console.error('Error al descargar el currículum:', error);
    res.status(500).json({ error: 'Error al descargar el currículum' });
  }
};

