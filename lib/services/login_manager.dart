import 'package:flutter/material.dart';
import 'package:test_drive/pages/email_list.dart';
import 'auth_service.dart';
import 'secure_storage_service.dart';

class LoginManager {
  static Future<void> login({
    required BuildContext context,
    required String username,
    required String password,
    required String server,
    required bool isSecure, // Added isSecure parameter
    required Function(bool, String?) onLoginResult,
  }) async {
    bool isAuthenticated = await AuthService.authenticate(
      username: username,
      password: password,
      server: server,
      isSecure: isSecure, // Pass the isSecure parameter
    );
    if (isAuthenticated) {
      await SecureStorageService.saveCredentials(username, password, server, isSecure);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailListPage(username: username, password: password, server: server, isSecure: isSecure),
          ),
        );
      }
      onLoginResult(true, null);
    } else {
      onLoginResult(false, 'Authentication failed! Please enter valid credentials.');
    }
  }
}
