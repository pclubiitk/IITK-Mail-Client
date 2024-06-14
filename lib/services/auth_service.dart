import 'package:enough_mail/enough_mail.dart';

class AuthService {
  static Future<bool> authenticate({
    required String username,
    required String password,
    required String server,
    required bool isSecure, // Added isSecure parameter
  }) async {
    final client = ImapClient(isLogEnabled: false);
    final int port = isSecure ? 993 : 143; // Select port based on isSecure
    try {
      await client.connectToServer('qasid.$server', port, isSecure: isSecure);
      await client.login(username, password);
      await client.logout();
      return true;
    } on ImapException {
      return false;
    }
  }
}
