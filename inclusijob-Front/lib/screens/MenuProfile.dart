import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inclusijob',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HomePage(),

    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showPopup = true;

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
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.black),
          onPressed: () {
            // Abrir el menú lateral
            Scaffold.of(context).openDrawer();
          },
        ),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context), // Menú lateral
      body: Stack(
        children: [
          ListView(
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
              ...List.generate(3, (index) {
                return _buildCurriculumItem();
              }),
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
                // Acción para favoritos
              },
            ),
          ),
        ),
      ),
    );
  }

  // Función para construir el menú lateral
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.person, size: 80, color: Colors.black),
                SizedBox(height: 8),
                Text(
                  '[Nombre del usuario]',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            text: 'Informacion Personal',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.file_present,
            text: 'Curriculum',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/curriculum-form');
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            text: 'Notificaciones',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            icon: Icons.favorite,
            text: 'Guardados',
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Función para construir un ítem del menú lateral
  Widget _buildDrawerItem({required IconData icon, required String text, required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text, style: const TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }

  Widget _buildCurriculumItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/pdf_icon.png',
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Nombre completo',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black, size: 24),
            onPressed: () {
              // Acción para descargar currículum
            },
          ),
        ],
      ),
    );
  }
}
