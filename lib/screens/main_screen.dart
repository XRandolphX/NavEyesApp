import 'package:MyEyesApp/views/detector_view.dart';
import 'package:MyEyesApp/views/welcome_view.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Esquema de color si gustas puedes usar las propiedades de Colors noramles y ver que color le cae.
    final colors = Theme.of(context).colorScheme;

    final screens = [WelcomeView(), YoloVideo()];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedFontSize: 0.0,
        selectedFontSize: 0.0,
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: colors.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_outlined),
            activeIcon: Icon(Icons.camera),
            label: 'Detector',
            backgroundColor: colors.tertiary,
          ),
        ],
      ),
    );
  }
}
