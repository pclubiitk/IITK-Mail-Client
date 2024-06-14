import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData getTheme() {
    return _isDarkMode ? _buildDarkTheme() : _buildLightTheme();
  }

  /// Light theme configuration
  ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: const Color.fromARGB(255, 5, 5, 5),
      useMaterial3: true,
      iconTheme: const IconThemeData(color: Colors.black),
      inputDecorationTheme:  InputDecorationTheme(
        fillColor: Colors.grey[300],
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color.fromARGB(255, 240, 240, 240),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 245, 243, 243),
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
    );
  }

  /// Dark theme configuration
  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      primaryColor: const Color.fromARGB(255, 226, 230, 232),
      useMaterial3: true,
      iconTheme: const IconThemeData(color: Colors.white),
      inputDecorationTheme:  InputDecorationTheme(
        fillColor: Colors.grey[900],
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color.fromRGBO(56, 57, 69, 0.941),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
