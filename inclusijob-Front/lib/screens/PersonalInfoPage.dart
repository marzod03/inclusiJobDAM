import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusijob/services/api_service.dart';

class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  // Controladores de texto para cada campo
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null) {
      final userProfile = await ApiService().fetchUserProfile(token);
      if (userProfile != null) {
        setState(() {
          _nameController.text = userProfile['nombre'] ?? '';
          _emailController.text = userProfile['correo'] ?? '';
          _phoneController.text = userProfile['telefono'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar los datos del usuario")),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error: Token no encontrado.');
    }
  }

  Future<void> _saveChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwtToken');

    if (token != null) {
      // Llama a la API para actualizar los datos del usuario
      bool success = await ApiService().updateUserProfile(
        token,
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Información actualizada con éxito")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al actualizar la información")),
        );
      }
    } else {
      print('Error: Token no encontrado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Información personal"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(Icons.person, "Nombre del usuario", _nameController),
                  _buildTextField(Icons.email, "Correo del usuario", _emailController),
                  _buildTextField(Icons.phone, "Telefono del usuario", _phoneController),
                  _buildTextField(
                    Icons.lock,
                    "Actualizar Contraseña",
                    _passwordController,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text("Guardar"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(IconData icon, String labelText, TextEditingController controller,
      {bool obscureText = false, bool enabled = true, Widget? suffixIcon}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: labelText,
                  border: InputBorder.none,
                  suffixIcon: suffixIcon,
                ),
                obscureText: obscureText,
                enabled: enabled,
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
