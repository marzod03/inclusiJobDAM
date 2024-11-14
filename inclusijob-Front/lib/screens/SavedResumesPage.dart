import 'package:flutter/material.dart';
import 'package:inclusijob/services/api_service.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class SavedResumesPage extends StatelessWidget {
  final List<Map<String, dynamic>> savedCurriculums;
  final ApiService _apiService = ApiService();

  SavedResumesPage({required this.savedCurriculums});

  Future<void> _openPdf(BuildContext context, int curriculumId, String fileName) async {
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
    } else {
      print("Token no encontrado. No se puede abrir el archivo.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currículums Guardados')),
      body: savedCurriculums.isEmpty
          ? const Center(child: Text("No hay currículums guardados"))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: savedCurriculums.length,
              itemBuilder: (context, index) {
                final curriculum = savedCurriculums[index];
                final fileName = curriculum['nombre_archivo'] ?? 'resume_$index';
                final curriculumId = curriculum['id']; // ID del curriculum para obtenerlo

                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, size: 60, color: Colors.red),
                        onPressed: () => _openPdf(context, curriculumId, fileName),
                      ),
                      const SizedBox(height: 10),
                      Text(fileName, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// Página de visualización de PDF
class PdfViewerPage extends StatelessWidget {
  final String filePath;

  PdfViewerPage({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ver PDF")),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
