import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ApiService {
  final String _baseUrl = 'http://172.20.10.2:5000';

  // Método para iniciar sesión
  Future<String?> login(String correo, String contrasena) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwtToken', token);
      return token;
    } else {
      print('Error en el inicio de sesión: ${response.body}');
      return null;
    }
  }

  // Método para obtener el perfil del usuario (requiere token)
  Future<Map<String, dynamic>?> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error al obtener el perfil del usuario: ${response.body}');
      return null;
    }
  }

  // Método para actualizar el perfil del usuario
  Future<bool> updateUserProfile(String token, String nombre, String correo, String telefono, [String? contrasena]) async {
    final body = {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
    };

    if (contrasena != null && contrasena.isNotEmpty) {
      body['contrasena'] = contrasena;
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/api/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print('Perfil actualizado exitosamente');
      return true;
    } else {
      print('Error al actualizar el perfil: ${response.body}');
      return false;
    }
  }

  // Método para obtener el token desde SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  // Método opcional para cerrar sesión y eliminar el token
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
  }

  // Método de registro
  Future<bool> register(String nombre, String correo, String telefono, String contrasena) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'contrasena': contrasena,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Error en el registro: ${response.body}');
      return false;
    }
  }

Future<bool> createCurriculum(String token, Map<String, dynamic> formData, File file) async {
  final uri = Uri.parse('$_baseUrl/api/curriculum/create');
  final request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Bearer $token';

  // Agrega los campos al formulario
  formData.forEach((key, value) {
    request.fields[key] = value.toString();
  });

  // Agrega el archivo al formulario
  request.files.add(await http.MultipartFile.fromPath('file', file.path));

  final response = await request.send();

  if (response.statusCode == 201) {
    print('Currículum creado exitosamente');
    return true;
  } else {
    print('Error al crear el currículum');
    return false;
  }
}

  // Método para obtener la lista de currículums guardados en la base de datos
  Future<List<Map<String, dynamic>>> fetchCurriculums(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/curriculums'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('Datos de currículums obtenidos: $data');
      return List<Map<String, dynamic>>.from(data);
    } else {
      print('Error al obtener los currículums: ${response.body}');
      return [];
    }
  }

  // Método para descargar un curriculum en PDF
  Future<File?> downloadCurriculumPDF(int curriculumId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/curriculums/$curriculumId/download'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final output = await getTemporaryDirectory();
      final filePath = "${output.path}/curriculum_$curriculumId.pdf";
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return file;
    } else {
      print('Error al descargar el PDF: ${response.body}');
      return null;
    }
  }

}
