import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_drive/pages/login_page.dart';
import 'package:test_drive/pages/email_list.dart';
import 'package:test_drive/services/auth_service.dart';
import 'package:test_drive/services/secure_storage_service.dart';

///Encrytion Commit
///When the app starts, it retrieve the credentials from storage,
///if they are null it navigates to login page, otherwise it authenticates the saved
///credentials and navigates to email view page if correct otherwise to login page


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
      theme: themeNotifier.isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
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
      inputDecorationTheme: InputDecorationTheme(
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

/// Class for managing theme state
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
