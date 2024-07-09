import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:iitk_mail_client/route_provider.dart';
import 'package:provider/provider.dart';
import 'Dependency_Injection.dart';
import 'package:iitk_mail_client/pages/login_page.dart';
import 'package:iitk_mail_client/pages/email_list.dart';
import 'package:iitk_mail_client/services/auth_service.dart';
import 'package:iitk_mail_client/services/secure_storage_service.dart';
import 'package:iitk_mail_client/theme_notifier.dart'; 
import 'Storage/initializeobjectbox.dart' ;
import 'models/advanced_settings_model.dart';
import 'package:get/get.dart';

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
  final isLogged = await SecureStorageService.getLoggedIn();

  String initialRoute = '/login';
  String? validUsername;
  String? validPassword;

  final _connectivityResult = await Connectivity().checkConnectivity();

  if(isLogged == "true"){
    initialRoute = '/emailList';
    validUsername = savedUsername;
    validPassword = savedPassword;
    if (_connectivityResult != ConnectivityResult.none){
      String? authResult = await AuthService.authenticate(
        emailSettings: emailSettings,
        username: savedUsername!,
        password: savedPassword!,
      );

      if (authResult != null) {
        initialRoute = '/login';
      }
    }
  }


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => EmailSettingsModel()),
        ChangeNotifierProvider(create: (_) => RouteProvider(initialRoute)),
      ],
      child: MyApp(
        savedUsername: validUsername,
        savedPassword: validPassword,
        emailSettings: emailSettings,
      ),
    ),
  );
  DependencyInjection.init();

}
class MyApp extends StatelessWidget {
  final String? savedUsername;
  final String? savedPassword;
  final EmailSettingsModel emailSettings;
  

  const MyApp({
    super.key,
    this.savedUsername,
    this.savedPassword,
    required this.emailSettings,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final routeProvider = Provider.of<RouteProvider>(context);


    return GetMaterialApp(
      title: 'IITK Mail-Client',
      theme: themeNotifier.getTheme(),
      initialRoute: routeProvider.initialRoute,
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