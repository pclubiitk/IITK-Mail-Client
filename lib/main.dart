import 'package:flutter/material.dart';
import 'package:test_drive/pages/login_page.dart';
import 'package:test_drive/pages/email_list.dart';
import 'services/auth_service.dart';
import 'services/secure_storage_service.dart';
import 'package:provider/provider.dart';
import 'models/advanced_settings_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final emailSettings = await SecureStorageService.loadSettings();
  final savedUsername = await SecureStorageService.getUsername();
  final savedPassword = await SecureStorageService.getPassword();

  String initialRoute = '/login';
  String? validUsername;
  String? validPassword;

  if (savedUsername != null && savedPassword != null) {
    String? authResult = await AuthService.authenticate(
      emailSettings: emailSettings,
      username: savedUsername,
      password: savedPassword,
    );

    if (authResult == null) {
      initialRoute = '/emailList';
      validUsername = savedUsername;
      validPassword = savedPassword;
    }
  }

  runApp(MyApp(
    initialRoute: initialRoute,
    savedUsername: validUsername,
    savedPassword: validPassword,
    emailSettings: emailSettings,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String? savedUsername;
  final String? savedPassword;
  final EmailSettingsModel emailSettings;

  const MyApp({
    required this.initialRoute,
    this.savedUsername,
    this.savedPassword,
    required this.emailSettings,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => emailSettings,
      child: MaterialApp(
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
      ),
    );
  }
}
