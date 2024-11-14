import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:inclusijob/screens/PersonalInfoPage.dart';
import 'package:inclusijob/screens/SavedResumesPage.dart';
import 'package:inclusijob/screens/CurriculumFormPage.dart';
import 'package:inclusijob/services/api_service.dart';
import 'package:inclusijob/screens/PdfViewerPage.dart' as pdf_viewer;
import 'package:inclusijob/screens/SavedResumesPage.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  bool _showPopup = true;
  Map<String, dynamic>? userProfile;
  List<Map<String, dynamic>> curriculums = [];
  List<Map<String, dynamic>> savedCurriculums = []; // Lista para currículums guardados

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadCurriculums();
  }

  Future<void> _fetchUserProfile() async {
    final token = await _apiService.getToken();
    if (token != null) {
      final profile = await _apiService.fetchUserProfile(token);
      setState(() {
        userProfile = profile;
      });
    } else {
      print('Error: Token no encontrado.');
    }
  }

  Future<void> _loadCurriculums() async {
    final token = await _apiService.getToken();
    if (token != null) {
      final fetchedCurriculums = await _apiService.fetchCurriculums(token);
      setState(() {
        curriculums = fetchedCurriculums;
      });
    } else {
      print('Error al cargar los currículums: Token no encontrado');
    }
  }

  void _saveCurriculum(Map<String, dynamic> curriculum) {
    setState(() {
      savedCurriculums.add(curriculum);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Currículum guardado en favoritos")),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'INCLUSIJOB',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      centerTitle: true,
    ),
    drawer: _buildProfileDrawer(context),
    body: Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadCurriculums, // Método que se ejecuta al hacer "pull-to-refresh"
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              const SizedBox(height: 10),
              const Text(
                'Curriculums',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (curriculums.isEmpty)
                const Center(child: Text('No hay currículums disponibles'))
              else
                for (var curriculum in curriculums) _buildCurriculumItem(curriculum),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: '¿Quieres compartir tu currículum? ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Hazlo aquí',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/curriculum-form');
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        if (_showPopup)
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '¿Ya hiciste tu curriculum?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showPopup = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.edit, size: 50, color: Colors.black),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/curriculum-form');
                    },
                    child: const Text(
                      'Hazlo aquí',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
    bottomNavigationBar: BottomAppBar(
      color: const Color.fromARGB(255, 212, 57, 0),
      child: SizedBox(
        height: 60,
        child: Center(
          child: IconButton(
            icon: const Icon(Icons.favorite, color: Color.fromARGB(255, 0, 0, 0), size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedResumesPage(savedCurriculums: savedCurriculums)),
              );
            },
          ),
        ),
      ),
    ),
  );
}


Widget _buildCurriculumItem(Map<String, dynamic> curriculum) {
  final isSaved = savedCurriculums.contains(curriculum);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 80),
          onPressed: () => _openPDF(curriculum['id']),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            curriculum['nombre_archivo'] ?? 'Currículum',
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        ),
        IconButton(
          icon: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
          ),
          onPressed: () {
            setState(() {
              if (isSaved) {
                savedCurriculums.remove(curriculum);
              } else {
                savedCurriculums.add(curriculum);
              }
            });
          },
        ),
      ],
    ),
  );
}


Future<void> _openPDF(int curriculumId) async {
  final token = await _apiService.getToken();
  if (token != null) {
    final file = await _apiService.downloadCurriculumPDF(curriculumId, token);
    if (file != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(filePath: file.path),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al abrir el PDF")),
      );
    }
  }
}



  Widget _buildProfileDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.grey),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  userProfile?['nombre'] ?? '[Nombre del usuario]',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Información Personal'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PersonalInfoPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Crear Curriculum'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/curriculum-form');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Guardados'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedResumesPage(savedCurriculums: savedCurriculums),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
