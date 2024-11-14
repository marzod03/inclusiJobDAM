import 'package:flutter/material.dart';
import 'screens/home_page.dart' as home_page;
import 'screens/login_page.dart' as login_page; 
import 'screens/CurriculumFormPage.dart' as form_page; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inclusijob',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // Ruta inicial
      initialRoute: '/login',
      // Rutas de la aplicación
      routes: {
        '/login': (context) => const login_page.LoginPage(), 
        '/home': (context) => home_page.HomePage(), 
        '/curriculum-form': (context) => form_page.CurriculumFormPage(), 
      },
      debugShowCheckedModeBanner: false, 
    );
  }
}
