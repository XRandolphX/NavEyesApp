import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  FlutterTts _flutterTts = FlutterTts();

  late String _formattedDate;
  //double _currentSliderValue = 20; // Valor inicial del volumen

  @override
  void initState() {
    super.initState();
    // Configuraciones iniciales del TTS
    _initializeTts();
    // Obtener la fecha actual
    _getCurrentDate();
    // Iniciar temporizador para mostrar la descripción después de 3 segundos
    // Timer(const Duration(seconds: 3), () {
    //   setState(() {
    //     // Simular la acción de presionar el botón "Comenzar"
    //     _startButtonPressed();
    //   });
    // });
  }

  // Método para inicializar el TTS
  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('es-ES');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.7);
  }

  @override
  void dispose() async {
    _flutterTts.stop();
    super.dispose();
  }

  // Método para activar la reproducción del texto
  _speakText(String text) async {
    await _flutterTts.speak(text);
  }

  _speakTexts(List<String> texts) async {
    for (var i = 0; i < texts.length; i++) {
      var text = texts[i];
      await _speakText(text);
      // Si no es el último texto y el siguiente texto es más largo que el actual
      if (i < texts.length - 1 && texts[i + 1].length > text.length) {
        // Pausa más larga antes del texto más largo
        await Future.delayed(Duration(seconds: 3));
      } else {
        // Pausa estándar entre los textos
        await Future.delayed(Duration(seconds: 15));
      }
    }
  }

  // Método para obtener la fecha actual y formatearla
  void _getCurrentDate() {
    DateTime now = DateTime.now();
    String month = '';
    switch (now.month) {
      case 1:
        month = 'Enero';
        break;
      case 2:
        month = 'Febrero';
        break;
      case 3:
        month = 'Marzo';
        break;
      case 4:
        month = 'Abril';
        break;
      case 5:
        month = 'Mayo';
        break;
      case 6:
        month = 'Junio';
        break;
      case 7:
        month = 'Julio';
        break;
      case 8:
        month = 'Agosto';
        break;
      case 9:
        month = 'Septiembre';
        break;
      case 10:
        month = 'Octubre';
        break;
      case 11:
        month = 'Noviembre';
        break;
      case 12:
        month = 'Diciembre';
        break;
      default:
        month = '';
    }
    _formattedDate = '${now.day} $month, ${now.year}';
  }

  // Método para simular la acción de presionar el botón "Comenzar"
  // void _startButtonPressed() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const Camara()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Llamar al método _speakTexts() con la lista de textos
          _speakTexts([
            'Hola, ¡Bienvenido!',
            'NavEyes mejora la navegación para personas con discapacidad visual. Con funciones accesibles, facilita la orientación y proporciona información en tiempo real para explorar el entorno con confianza',
            'El Botón de Comenzar se presionará automáticamente después de 3 segundos',
          ]);
        },
        child: const Icon(Icons.speaker_phone),
      ),
      backgroundColor: const Color.fromARGB(255, 66, 82, 183),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  // Primera fila de saludo y fecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Texto de saludo
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hola!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formattedDate,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 164, 167, 188),
                            ),
                          )
                        ],
                      ),
                      // Icono de volumen del asistente de voz
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: const Color.fromARGB(255, 76, 99, 184),
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   padding: const EdgeInsets.all(12),
                      //   child: const Icon(
                      //     Icons.volume_up,
                      //     color: Colors.white,
                      //     size: 30,
                      //   ),
                      // )
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Segunda fila de texto
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 76, 99, 184),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () {
                        _speakText(
                            'NavEyes mejora la navegación para personas con discapacidad visual. Con funciones accesibles, facilita la orientación y proporciona información en tiempo real para explorar el entorno con confianza');
                      },
                      child: Text(
                        'NavEyes mejora la navegación para personas con discapacidad visual. Con funciones accesibles, facilita la orientación y proporciona información en tiempo real para explorar el entorno con confianza',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Segundo Bloque con el botón de acceso
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(243, 0, 0, 0), // Color de la sombra
                      offset: Offset(0,
                          2), // Desplazamiento de la sombra (horizontal, vertical)
                      blurRadius: 4, // Radio de desenfoque de la sombra
                      spreadRadius: 1, // Extensión de la sombra
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navegar a la pantalla Camera.dart cuando se presione el botón
                          _speakText('Comenzando, abriendo cámara');
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => const Camara()),
                          // );
                        },
                        child: const Text('Comenzar'),
                      ),
                      const SizedBox(
                          height:
                              20), // Espacio entre el botón y la descripción
                      GestureDetector(
                        onTap: () {
                          _speakText(
                              'El Botón de "Comenzar" se presionará automáticamente después de 3 segundos');
                        },
                        child: const Text(
                          'El Botón de "Comenzar" se presionará automáticamente después de 3 segundos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 66, 82, 183),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
