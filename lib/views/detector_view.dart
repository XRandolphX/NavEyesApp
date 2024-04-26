import 'package:camera/camera.dart'; // camera: Este paquete proporciona la funcionalidad para acceder a la cámara del dispositivo.
import 'package:flutter_tts/flutter_tts.dart'; // Este paquete permite la conversión de texto en voz.
import 'package:flutter_vision/flutter_vision.dart'; // Paquete que proporciona acceso a modelos de visión artificial, en este caso, el modelo YOLO.
import 'package:flutter/material.dart'; // Este paquete proporciona widgets de interfaz de usuario para crear aplicaciones de material design en Flutter.
import 'dart:async'; // Esta biblioteca proporciona más herramientas para crear, consumir y transformar futuros y flujos.

late List<CameraDescription> cameras;

/*
YOLO REAL-TIME OBJECT DETECTION
La clase YoloVideo es un StatefulWidget que representa la pantalla principal de la aplicación. Esta clase se encarga de la inicialización de la cámara, la carga del modelo YOLO y la visualización de los resultados de detección de objetos en la cámara en tiempo real.
*/
class YoloVideo extends StatefulWidget {
  const YoloVideo({super.key});

  @override
  State<YoloVideo> createState() => _YoloVideoState();
}

// El estado _YoloVideoState contiene la lógica para controlar la cámara, iniciar y detener la detección de objetos, así como la carga del modelo YOLO y la visualización de los resultados en la interfaz de usuario.
class _YoloVideoState extends State<YoloVideo> {
  late CameraController controller;
  late List<Map<String, dynamic>> yoloResults;
  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;

  late FlutterVision vision; // YOLO
  FlutterTts flutterTtsYolo = FlutterTts(); // TTS

  late Timer _detectionTimer; // Timer para controlar la velocidad de detección
  bool _isSpeaking = false; // Bandera para controlar si el TTS está hablando

// En el método initState(), se inicializa la cámara, se carga el modelo YOLO y se inicia la inicialización de TTS (Texto a voz).
  @override
  void initState() {
    super.initState();

    vision = FlutterVision(); // YOLO
    initTTS(); // TTS: El método initTTS() inicializa el motor de TTS y establece sus configuraciones.
    init(); // Inciializa Cámara y Modelo YOLO
    // Decir la frase al inicio
    speak(
        "Estás en la Sección de detección de Objetos, presione el botón para comenzar a detectar.");
  }

  // El método dispose() se llama cuando el widget se elimina del árbol de widgets. Se encarga de liberar recursos, detener la cámara y cerrar el modelo YOLO.
  @override
  void dispose() async {
    // await stopDetection(); // Detener la detección antes de liberar recursos

    flutterTtsYolo.stop(); // TTS Stop
    vision.closeYoloModel(); // YOLO Stop

    controller.dispose();

    super.dispose();
  }

  void _startDetectionWithDelay() {
    const detectionInterval =
        Duration(milliseconds: 800); // Intervalo de detección (0.5 segundos)
    _detectionTimer = Timer.periodic(detectionInterval, (timer) async {
      if (!isDetecting) {
        await startDetection(); // Iniciar detección si no está en curso
      }
    });
  }

// Los métodos startDetection() y stopDetection() se utilizan para iniciar y detener la detección de objetos respectivamente.
  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
      _startDetectionWithDelay(); // Iniciar detección con retraso
    });
    if (controller.value.isStreamingImages) {
      return;
    }
    await controller.startImageStream((image) async {
      if (isDetecting) {
        //Imagen con el Porcentaje
        cameraImage = image;
        //Los frames que detecta la cámara
        yoloOnFrame(image);
      }
    });
  }

  Future<void> stopDetection() async {
    setState(() {
      isDetecting = false;
      yoloResults.clear();
    });
    _detectionTimer.cancel(); // Cancelar el timer al eliminar el widget
  }

// El método initTTS() inicializa el motor de TTS y establece sus configuraciones.
  Future<void> initTTS() async {
    // TTS
    await flutterTtsYolo.setLanguage("es-ES"); // Set the language you want
    await flutterTtsYolo
        .setSpeechRate(0.6); // Adjust speech rate (1.0 is normal)
    await flutterTtsYolo.setVolume(1.0); // Adjust volume (0.0 to 1.0)
    await flutterTtsYolo.setPitch(1.0); // Adjust pitch (1.0 is normal)
  }

// El método speak() se utiliza para convertir texto en habla utilizando el motor TTS.
  Future<void> speak(String text) async {
    await flutterTtsYolo.speak(text); // TTS
  }

// El método init() se encarga de inicializar la cámara, cargar el modelo YOLO y establecer el estado inicial de la detección de objetos.
  init() async {
    cameras = await availableCameras();
    controller =
        CameraController(cameras[0], ResolutionPreset.max, enableAudio: false);
    controller.initialize().then((value) {
      loadYoloModel().then((value) {
        setState(() {
          isLoaded = true;
          isDetecting = false;
          yoloResults = [];
        });
        // startDetection();
      });
    });
  }

// El método loadYoloModel() carga el modelo YOLO.
  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: 'assets/labelv8.txt',
        modelPath: 'assets/yolov8n_float32.tflite',
        modelVersion: "yolov8",
        numThreads: 8,
        useGpu: true);
    setState(() {
      isLoaded = true;
    });
  }

// El método yoloOnFrame() se llama cada vez que se captura un nuevo fotograma de la cámara y realiza la detección de objetos en ese fotograma.
  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
        bytesList: cameraImage.planes
            .map((plane) => plane.bytes)
            .toList(), // Aquí se espera una lista de bytes que representan la imagen de la cámara.
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold:
            0.4, // Este parámetro se refiere al umbral de IoU (Intersección sobre Unión), que es un valor entre 0 y 1 que determina cuánto deben superponerse dos cuadros delimitadores para que se consideren como uno solo. En este caso, si la superposición entre dos cuadros delimitadores es mayor o igual a 0.4, se fusionarán en uno solo.
        confThreshold:
            0.4, //  Umbral de confianza de detección. Solo se considerarán las detecciones con una confianza del 40% o más.
        classThreshold:
            0.5); // Umbral de confianza de clase. Se aplica a cada clase individualmente. 50% o más

    if (result.isNotEmpty && !_isSpeaking) {
      setState(() {
        yoloResults = result;
      });
      _speakResults(); // Iniciar pronunciación si hay resultados y no se está hablando
    }
  }

  Future<void> _speakResults() async {
    _isSpeaking = true; // Marcar que el TTS está hablando
    final List<Map<String, dynamic>> resultsCopy =
        List.from(yoloResults); // Crear una copia de yoloResults
    for (final result in resultsCopy) {
      final text = "${result['tag']}";
      await speak(text); // Pronunciar el texto
      await Future.delayed(
          Duration(seconds: 2)); // Esperar 1 segundo entre pronunciaciones
    }
    _isSpeaking = false; // Marcar que el TTS ha terminado de hablar
  }

// El método displayBoxesAroundRecognizedObjects() muestra cuadros delimitadores alrededor de los objetos detectados en la vista previa de la cámara.
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    // Si la lista de resultados de detección yoloResults está vacía, la función devuelve una lista vacía.
    if (yoloResults.isEmpty) return [];
/*
Se calculan dos factores de escala (factorX y factorY) que se utilizan para ajustar las coordenadas de los cuadros delimitadores de los objetos detectados según el tamaño de la pantalla y la imagen de la cámara.
'??' Operador de fusión nula (null-aware coalescing operator) en Dart. Significa que si el valor de la izquierda es nulo, se utiliza el de la derecha, es decir el 1. Se hace esto para evitar errores de división por cero.
Entonces, en conjunto, cameraImage?.height ?? 1 se lee como "si cameraImage no es nulo, obtén su altura; de lo contrario, usa 1".
*/
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);
// Se define un color llamado colorPick que se utiliza para el fondo del texto dentro de los cuadros delimitadores.
    Color colorPick = Color.fromARGB(255, 76, 99, 184);

// Esta línea inicia el proceso de mapeo sobre cada elemento en la lista yoloResults. Para cada elemento de yoloResults, se ejecutará el código dentro del cuerpo de la función de mapeo.
    return yoloResults.map((result) {
      speak(
          "${result['tag']}"); // Convierte el nombre del objeto detectado en habla.
// Para cada resultado de detección, se devuelve un widget Positioned. Este widget se utiliza para posicionar otros widgets en una pila.
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          // Container representa el cuadro delimitador alrededor del objeto detectado.
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border:
                Border.all(color: Color.fromARGB(255, 76, 99, 184), width: 3.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList(); // Finalmente, la función map devuelve un Iterable, por lo que se llama a toList() para convertirlo en una lista de widgets y devolver esa lista como resultado de la función.
  }

// En el método build(), se construye la interfaz de usuario de la pantalla principal. Muestra la vista previa de la cámara y los resultados de la detección de objetos. También proporciona botones para iniciar y detener la detección de objetos.
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text("Model not loaded. Waiting for it.",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(
            controller,
          ),
        ),
        ...displayBoxesAroundRecognizedObjects(size),
        Positioned(
          bottom: 75,
          width: MediaQuery.of(context).size.width,
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  width: 5, color: Colors.white, style: BorderStyle.solid),
            ),
            child: isDetecting
                ? IconButton(
                    onPressed: () async {
                      stopDetection();
                    },
                    icon: const Icon(
                      Icons.stop,
                      color: Colors.red,
                    ),
                    iconSize: 50,
                  )
                : IconButton(
                    onPressed: () async {
                      await startDetection();
                    },
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 50,
                  ),
          ),
        ),
      ],
    );
  }
}
