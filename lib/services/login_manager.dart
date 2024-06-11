import 'package:flutter/material.dart';
import 'package:test_drive/pages/email_list.dart';
import 'auth_service.dart';

/// the login method uses AuthService method to verify the credentials, 
/// if credentials are verified, it navigates to Email list page

class LoginManager {
  static Future<void> login({
    required BuildContext context,
    required String username,
    required String password,
    required Function(bool, String?) onLoginResult,
  }) async {
    bool isAuthenticated = await AuthService.authenticate(
      username: username,
      password: password,
    );
    if (isAuthenticated) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailListPage(username: username, password: password),
          ),
        );
      }
      onLoginResult(true, null);
    } else {
      onLoginResult(false, 'Authentication failed! Please enter valid credentials.');
    }
  }
}
