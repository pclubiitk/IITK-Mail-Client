import 'package:flutter/material.dart';
import 'package:test_drive/pages/login_page.dart';
import 'package:test_drive/pages/email_list.dart';
import 'services/auth_service.dart';
import 'services/secure_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedUsername = await SecureStorageService.getUsername();
  final savedPassword = await SecureStorageService.getPassword();
  bool isAuthenticated = false;
  String initialRoute = '/login';
  String? validUsername;
  String? validPassword;

  if (savedUsername != null && savedPassword != null) {
    isAuthenticated = await AuthService.authenticate(
      username: savedUsername,
      password: savedPassword,
    );
    if (isAuthenticated) {
      initialRoute = '/emailList';
      validUsername = savedUsername;
      validPassword = savedPassword;
    }
  }

  runApp(MyApp(
    initialRoute: initialRoute,
    savedUsername: validUsername,
    savedPassword: validPassword,
  ));
}



class MyApp extends StatelessWidget {
  final String initialRoute;
  final String? savedUsername;
  final String? savedPassword;

  const MyApp({
    required this.initialRoute,
    this.savedUsername,
    this.savedPassword,
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
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
