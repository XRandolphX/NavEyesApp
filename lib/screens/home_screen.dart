import 'dart:async';
import 'package:MyEyesApp/screens/main_screen.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _navigateToMenuPage(); // inicializa tiempo
  }

  void _navigateToMenuPage() {
    Timer(
      const Duration(seconds: 5), // Espera 5 segundos
      () {
        Navigator.of(context).pushReplacement(
          // Reemplaza la página actual con la página de menú principal
          MaterialPageRoute(
              builder: (BuildContext context) => const MainScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 66, 82, 183),
      body: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24.0,
              color: Colors.white,
            ),
            children: <TextSpan>[
              TextSpan(text: 'Bienvenido a '),
              TextSpan(
                text: 'NavEyes',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 30.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
