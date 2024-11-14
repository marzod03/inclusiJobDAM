const pool = require('../config/db');
const bcrypt = require('bcryptjs');

// Obtener datos de perfil del usuario
exports.getUserProfile = async (req, res) => {
  const { userId } = req.user;
  try {
    const result = await pool.query('SELECT id, nombre, correo, telefono FROM usuarios WHERE id = $1', [userId]);
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener el perfil del usuario' });
  }
};

// Actualizar perfil del usuario
exports.updateUserProfile = async (req, res) => {
  const { userId } = req.user;
  const { nombre, correo, telefono, contrasena } = req.body;
  
  try {
    let updateFields = [nombre, correo, telefono, userId];
    let query = 'UPDATE usuarios SET nombre = $1, correo = $2, telefono = $3';

    // Verificamos si se proporciona una nueva contraseña
    if (contrasena && contrasena.trim() !== '') {
      const hashedPassword = await bcrypt.hash(contrasena, 10);
      query += ', contrasena = $4';
      updateFields = [nombre, correo, telefono, hashedPassword, userId];
    }

    query += ' WHERE id = $' + (updateFields.length) + ' RETURNING id, nombre, correo, telefono';

    const result = await pool.query(query, updateFields);
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: 'Error al actualizar el perfil del usuario' });
  }
};

// Eliminar cuenta del usuario
exports.deleteUser = async (req, res) => {
  const { userId } = req.user;
  try {
    await pool.query('DELETE FROM usuarios WHERE id = $1', [userId]);
    res.json({ message: 'Cuenta eliminada correctamente' });
  } catch (error) {
    res.status(500).json({ error: 'Error al eliminar la cuenta' });
  }
};
