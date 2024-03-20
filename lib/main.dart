import 'package:MyEyesApp/screens/home_screen.dart';
import 'package:flutter/material.dart'; // Este paquete proporciona widgets de interfaz de usuario para crear aplicaciones de material design en Flutter.

// inicializa la aplicación y la ejecuta
void main() {
  runApp(const main_screen());
}

// La clase App es el widget de nivel superior que crea una instancia de MaterialApp, que es el widget raíz de la aplicación Flutter. Define el título de la aplicación, el tema y el widget de inicio.
class main_screen extends StatelessWidget {
  const main_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'NavEyesApp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const Home());
  }
}
