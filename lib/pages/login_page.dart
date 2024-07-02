import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:iitk_mail_client/pages/advanced_settings_page.dart';
import 'package:iitk_mail_client/services/login_manager.dart';
import 'package:iitk_mail_client/theme_notifier.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_isAuthenticated) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    await LoginManager.login(
      context: context,
      username: username,
      password: password,
      onLoginResult: (isAuthenticated, errorMessage) {
        setState(() {
          _isLoading = false;
          _isAuthenticated = isAuthenticated;
          _errorMessage = errorMessage;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

   return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.canvasColor,
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.primaryColor,
            ),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/en/thumb/a/a3/IIT_Kanpur_Logo.svg/800px-IIT_Kanpur_Logo.svg.png',
                    height: 110,
                    color: theme.iconTheme.color,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'IITK Mail-Client',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      hintText: 'Username',
                      hintStyle: theme.textTheme.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          Icon(Icons.person, color: theme.iconTheme.color),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      hintText: 'Password',
                      hintStyle: theme.textTheme.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          Icon(Icons.lock, color: theme.iconTheme.color),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    // width: double.infinity, 
                    // margin: const EdgeInsets.symmetric(horizontal: 110),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primaryColor
                    ),
                  onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdvancedSettingsPage(),
                  ),
                ),
                child: Text('Advanced Settings'),
              ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null && !_isLoading)
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 14 ,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
      ),
    ));
  }
}