import 'package:flutter/material.dart';
import 'package:test_drive/pages/email_list.dart';
import 'auth_service.dart';
import 'secure_storage_service.dart';
/// the login method uses AuthService method to verify the credentials, 
/// if credentials are verified, it navigates to Email list page and 
/// also save the credentials to flutter secure storage

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
      await SecureStorageService.saveCredentials(username, password);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailListPage(username: username,password: password,),
          ),
        );
      }
      onLoginResult(true, null);
    } else {
      onLoginResult(false, 'Authentication failed! Please enter valid credentials.');
    }
  }
}
