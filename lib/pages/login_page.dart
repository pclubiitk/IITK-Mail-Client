import 'package:flutter/material.dart';
import 'package:test_drive/services/login_manager.dart';

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
  bool _isSecure = true; // Default to secure
  String? _errorMessage;
  String _selectedServer = 'iitk.ac.in'; // Default selected server
  final List<String> _serverOptions = ['iitk.ac.in']; // List of server options

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
      server: _selectedServer,
      isSecure: _isSecure,
      onLoginResult: (isAuthenticated, errorMessage) {
        setState(() {
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
          _errorMessage = errorMessage;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Login'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButton<String>(
              dropdownColor: Colors.black,
              value: _selectedServer,
              icon: const Icon(Icons.arrow_downward, color: Colors.white),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.white),
              underline: Container(
                height: 2,
                color: Colors.white,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedServer = newValue!;
                });
              },
              items: _serverOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://upload.wikimedia.org/wikipedia/en/thumb/a/a3/IIT_Kanpur_Logo.svg/800px-IIT_Kanpur_Logo.svg.png',
                height: 110,
                color: Colors.white70,
              ),
              const SizedBox(height: 24),
              const Text(
                'IITK Mail-Client',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: 'Username',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Secure Connection',
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    value: _isSecure,
                    onChanged: (value) {
                      setState(() {
                        _isSecure = value;
                      });
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 110),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null && !_isLoading)
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
