import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveCredentials(String username, String password, String server, bool isSecure) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
    await _storage.write(key: 'server', value: server);
    await _storage.write(key: 'isSecure', value: isSecure.toString());
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }
  
  static Future<String?> getPassword() async {
    return await _storage.read(key: 'password');
  }
  
  static Future<String?> getServer() async {
    return await _storage.read(key: 'server');
  }

  static Future<bool> getSecure() async {
    final secureValue = await _storage.read(key: 'isSecure');
    return secureValue == 'true'; // Default to true if not set
  }

  static Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }
}
