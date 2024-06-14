import 'package:flutter/material.dart';
import 'package:test_drive/pages/login_page.dart';
import 'package:test_drive/pages/email_list.dart';
import 'services/auth_service.dart';
import 'services/secure_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedUsername = await SecureStorageService.getUsername();
  final savedPassword = await SecureStorageService.getPassword();
  final savedServer = await SecureStorageService.getServer();
  final isSecure = await SecureStorageService.getSecure();

  bool isAuthenticated = false;
  String initialRoute = '/login';
  String? validUsername;
  String? validPassword;
  String? validServer;

  if (savedUsername != null && savedPassword != null && savedServer != null) {
    isAuthenticated = await AuthService.authenticate(
      username: savedUsername,
      password: savedPassword,
      server: savedServer,
      isSecure: isSecure, // Pass isSecure to AuthService
    );
    if (isAuthenticated) {
      initialRoute = '/emailList';
      validUsername = savedUsername;
      validPassword = savedPassword;
      validServer = savedServer;
    }
  }

  runApp(MyApp(
    initialRoute: initialRoute,
    savedUsername: validUsername,
    savedPassword: validPassword,
    savedServer: validServer,
    isSecure: isSecure, // Pass isSecure to MyApp
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String? savedUsername;
  final String? savedPassword;
  final String? savedServer;
  final bool isSecure; // Add isSecure field

  const MyApp({
    required this.initialRoute,
    this.savedUsername,
    this.savedPassword,
    this.savedServer,
    required this.isSecure, // Initialize isSecure
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IITK Mail-Client',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/emailList': (context) => EmailListPage(
              username: savedUsername!,
              password: savedPassword!,
              server: savedServer!,
              isSecure: isSecure, // Pass isSecure to EmailListPage
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
