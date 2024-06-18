import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_drive/pages/email_list.dart';
import '../models/advanced_settings_model.dart';
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
    final emailSettings = Provider.of<EmailSettingsModel>(context, listen: false);

    String? errorMessage = await AuthService.authenticate(
      emailSettings: emailSettings,
      username: username,
      password: password,
    );

    if (errorMessage == null) {
      await SecureStorageService.saveCredentials(username, password);
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
      onLoginResult(false, errorMessage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
