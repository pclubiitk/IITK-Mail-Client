import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iitk_mail_client/pages/login_page.dart';
import 'package:iitk_mail_client/pages/email_list.dart';
import 'package:iitk_mail_client/services/auth_service.dart';
import 'package:iitk_mail_client/services/secure_storage_service.dart';
import 'package:iitk_mail_client/theme_notifier.dart'; 
import './EmailCache/initializeobjectbox.dart' ;
import 'models/advanced_settings_model.dart';

/// Encryption Commit
/// When the app starts, it retrieves the credentials from storage.
/// If they are null, it navigates to the login page. Otherwise, it authenticates
/// the saved credentials and navigates to the email view page if correct, otherwise to the login page.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeObjectBox() ;
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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => EmailSettingsModel()),
      ],
      child: MyApp(
        initialRoute: initialRoute,
        savedUsername: validUsername,
        savedPassword: validPassword,
        emailSettings: emailSettings,
      ),
    ),
  );
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