import 'package:flutter/material.dart';
import 'package:test_drive/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IITK Mail-Client',
      theme: ThemeData(
        useMaterial3: true
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

