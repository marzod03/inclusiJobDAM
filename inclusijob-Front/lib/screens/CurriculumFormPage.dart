import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

class CurriculumFormPage extends StatelessWidget {
  CurriculumFormPage({super.key});

  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _professionalLinkController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _responsibilitiesController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _projectsController = TextEditingController();
  final TextEditingController _certificationsController = TextEditingController();
  final TextEditingController _certificationNameController = TextEditingController();
  final TextEditingController _certificationInstitutionController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  final TextEditingController _projectsDescriptionController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _AblesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Curriculum'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CustomTextField(controller: _fileNameController, hintText: 'Nombre para el archivo (sin .pdf)'),
            CustomTextField(controller: _nameController, hintText: 'Nombre Completo'),
            CustomTextField(controller: _phoneController, hintText: 'Teléfono de contacto'),
            CustomTextField(controller: _emailController, hintText: 'Correo Electrónico'),
            CustomTextField(controller: _cityController, hintText: 'Ciudad'),
            CustomTextField(controller: _professionalLinkController, hintText: 'Enlace Profesional (Opcional)'),
            CustomTextField(controller: _summaryController, hintText: 'Resumen Profesional'),
            CustomTextField(controller: _skillsController, hintText: 'Párrafo que resume habilidades'),
            CustomTextField(controller: _experienceController, hintText: 'Experiencia Laboral'),
            CustomTextField(controller: _companyNameController, hintText: 'Nombre empresa previa'),
            CustomTextField(controller: _jobTitleController, hintText: 'Cargo desempeñado'),
            CustomTextField(controller: _responsibilitiesController, hintText: 'Descripción de responsabilidades'),
            CustomTextField(controller: _educationController, hintText: 'Educación'),
            CustomTextField(controller: _institutionController, hintText: 'Nombre institución'),
            CustomTextField(controller: _degreeController, hintText: 'Título Obtenido'),
            CustomTextField(controller: _projectsController, hintText: 'Proyectos destacados'),
            CustomTextField(controller: _certificationsController, hintText: 'Certificaciones y cursos'),
            CustomTextField(controller: _certificationNameController, hintText: 'Nombre certificación'),
            CustomTextField(controller: _certificationInstitutionController, hintText: 'Institución que lo otorgó'),
            CustomTextField(controller: _languagesController, hintText: 'Idiomas que domina'),
            CustomTextField(controller: _hobbiesController, hintText: 'Hobbies (Opcional)'),
            CustomTextField(controller: _AblesController, hintText: 'Discapacidad'),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _generateAndSavePDF(context),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndSavePDF(BuildContext context) async {
    final pdf = pw.Document();

    // Cargar la fuente Helvetica o una fuente personalizada
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final font = pw.Font.ttf(fontData.buffer.asByteData());

    // Genera el contenido del PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Curriculum Vitae', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: font)),
            pw.SizedBox(height: 20),
            pw.Text('Nombre Completo: ${_nameController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Teléfono: ${_phoneController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Correo Electrónico: ${_emailController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Ciudad: ${_cityController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Enlace Profesional: ${_professionalLinkController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Resumen Profesional: ${_summaryController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Habilidades: ${_skillsController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Experiencia Laboral: ${_experienceController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Nombre Empresa: ${_companyNameController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Cargo: ${_jobTitleController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Responsabilidades: ${_responsibilitiesController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Educación: ${_educationController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Institución: ${_institutionController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Título: ${_degreeController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Proyectos: ${_projectsController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Certificaciones: ${_certificationsController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Nombre Certificación: ${_certificationNameController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Institución que otorgó: ${_certificationInstitutionController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Idiomas: ${_languagesController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Hobbies: ${_hobbiesController.text}', style: pw.TextStyle(font: font)),
            pw.Text('Intereses: ${_AblesController.text}', style: pw.TextStyle(font: font)),
          ],
        ),
      ),
    );

    final fileName = _fileNameController.text.isNotEmpty ? _fileNameController.text : 'curriculum';
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(await pdf.save());

    await _uploadPDFToBackend(file, context, fileName);
  }

  Future<void> _uploadPDFToBackend(File file, BuildContext context, String fileName) async {
    final url = 'http://172.20.10.2:5000/api/curriculum/create';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el token de autenticación')),
      );
      return;
    }

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('archivo', file.path, filename: '$fileName.pdf'));

    final response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Currículum guardado exitosamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el currículum')),
      );
    }
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomTextField({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        ),
      ),
    );
  }
}
