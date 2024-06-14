import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_drive/pages/login_page.dart';
import 'package:test_drive/pages/email_list.dart';
import 'package:test_drive/services/auth_service.dart';
import 'package:test_drive/services/secure_storage_service.dart';
import 'package:test_drive/theme_notifier.dart'; 
import "EmailCache/initializeobjectbox.dart" ;

/// Encryption Commit
/// When the app starts, it retrieves the credentials from storage.
/// If they are null, it navigates to the login page. Otherwise, it authenticates
/// the saved credentials and navigates to the email view page if correct, otherwise to the login page.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeObjectBox() ;

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

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(), 
      child: MyApp(
        initialRoute: initialRoute,
        savedUsername: validUsername,
        savedPassword: validPassword,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String? savedUsername;
  final String? savedPassword;

  const MyApp({
    required this.initialRoute,
    this.savedUsername,
    this.savedPassword,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'IITK Mail-Client',
      theme: themeNotifier.getTheme(),
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
