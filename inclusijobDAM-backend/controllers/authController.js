const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Inicio de sesión
exports.login = async (req, res) => {
  const { correo, contrasena } = req.body;
  try {
    // Busca el usuario en la base de datos usando el correo
    const result = await pool.query('SELECT * FROM usuarios WHERE correo = $1', [correo]);
    const user = result.rows[0];
    
    // Verifica si el usuario existe y si la contraseña es correcta
    if (user && await bcrypt.compare(contrasena, user.contrasena)) {
      // Genera un token JWT si las credenciales son correctas
      const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
      res.json({ token });
    } else {
      // Responde con un error si las credenciales son incorrectas
      res.status(401).json({ error: 'Credenciales inválidas' });
    }
  } catch (error) {
    console.error('Error al iniciar sesión:', error);
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
};

// Registro de usuario
exports.register = async (req, res) => {
  const { nombre, correo, telefono, contrasena } = req.body;
  try {
    // Hashea la contraseña antes de guardarla
    const hashedPassword = await bcrypt.hash(contrasena, 10);
    // Inserta el usuario en la base de datos
    const result = await pool.query(
      'INSERT INTO usuarios (nombre, correo, telefono, contrasena) VALUES ($1, $2, $3, $4) RETURNING *',
      [nombre, correo, telefono, hashedPassword]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error al registrar usuario:', error);
    res.status(500).json({ error: 'Error al registrar usuario' });
  }
};

// Verificar el token de Google
exports.verifyGoogleToken = async (req, res) => {
  const { token } = req.body;
  console.log("Token recibido en el backend:", token);

  if (!token) {
    return res.status(400).json({ error: "Token no proporcionado" });
  }

  try {
    // Verifica el token de Google
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    console.log("Payload de Google:", payload);

    const { email, name } = payload;

    // Busca el usuario en la base de datos
    let result = await pool.query('SELECT * FROM usuarios WHERE correo = $1', [email]);
    let user = result.rows[0];

    // Si el usuario no existe, lo crea
    if (!user) {
      console.log("Usuario no encontrado en la base de datos. Creando uno nuevo.");
      const newUser = await pool.query(
        'INSERT INTO usuarios (nombre, correo) VALUES ($1, $2) RETURNING *',
        [name, email]
      );
      user = newUser.rows[0];
    }

    // Genera un token JWT para la sesión del usuario
    const jwtToken = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    console.log("Token JWT generado:", jwtToken);

    res.json({ token: jwtToken, user });
  } catch (error) {
    console.error('Error al verificar el token de Google:', error);
    res.status(401).json({ error: 'Token de Google inválido o expirado' });
  }
};
