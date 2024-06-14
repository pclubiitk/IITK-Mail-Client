import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_drive/pages/login_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'IITK Mail-Client',
      theme: themeNotifier.isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }

    ThemeData _buildLightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: const Color.fromARGB(255, 5, 5, 5),
      useMaterial3: true,
      iconTheme: const IconThemeData(color: Colors.black),
      inputDecorationTheme: InputDecorationTheme(
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

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      primaryColor: const Color.fromARGB(255, 226, 230, 232),
      useMaterial3: true,
      iconTheme: const IconThemeData(color: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.grey[900],
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color.fromRGBO(56, 57, 69, 0.941),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor:Colors.black,
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

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
