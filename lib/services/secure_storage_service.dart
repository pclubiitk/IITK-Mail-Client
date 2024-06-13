import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
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
}
