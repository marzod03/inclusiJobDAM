import 'package:flutter/material.dart';
import 'package:inclusijob/services/api_service.dart'; // Asegúrate de tener tu servicio de API correctamente importado
import 'package:inclusijob/screens/login_page.dart'; // Importa la página de inicio de sesión para redireccionar después del registro

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService(); // Instancia del servicio de API

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Llamada al servicio de API para registrar al usuario
      final success = await _apiService.register(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text,
      );

      if (success) {
        // Mostrar mensaje de registro exitoso
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registro exitoso'),
            content: const Text('Tu cuenta ha sido creada correctamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        // Mostrar mensaje de error si el registro falla
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error de registro'),
            content: const Text('No se pudo registrar el usuario.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Iniciar Sesion'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 20),
                // Campo de nombre completo
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre Completo',
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                // Campo de correo electrónico
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),
                // Campo de teléfono
                _buildTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  icon: Icons.phone,
                ),
                const SizedBox(height: 20),
                // Campo de contraseña
                _buildTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                // Botón de registro
                ElevatedButton(
                  onPressed: _register, // Llama al método de registro
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF757575),
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para los campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingresa tu $label';
        }
        return null;
      },
    );
  }
}
