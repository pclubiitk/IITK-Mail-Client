import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/advanced_settings_model.dart';
import 'dart:convert';

///We first create an instance of storage and then use save credentials function to save them
///Call the functions getUsername and getPassword whenever we want to use saved credentials
///for reference, go to main.dart where I have used the stored credentials
///The email settings key stores the configuration of advanced settings in a model named emailSettings.

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  static Future<void> setLoggedIn(String loggedIn) async {
    await _storage.write(key: 'isLogged', value: loggedIn);
  }

  static Future<String?> getLoggedIn() async {
    return await _storage.read(key: 'isLogged');
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }
  
  static Future<String?> getPassword() async {
    return await _storage.read(key: 'password');
  }

  static Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }

  static Future<void> saveSettings(EmailSettingsModel settings) async {
    await _storage.write(key: 'emailSettings', value: jsonEncode(settings.toJson()));
  }

  static Future<EmailSettingsModel> loadSettings() async {
    final settingsString = await _storage.read(key: 'emailSettings');
    if (settingsString != null) {
      final settingsJson = jsonDecode(settingsString);
      final settings = EmailSettingsModel();
      settings.fromJson(settingsJson);
      return settings;
    }
    return EmailSettingsModel(); 
  }
}
