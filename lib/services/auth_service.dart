import 'package:enough_mail/enough_mail.dart';
import 'dart:io';
import 'dart:async';
import '../models/advanced_settings_model.dart';
/// The authenticate method of AuthService verifies the credentials from IMTP server of iitk
/// Throws an [ImapException] if there is an error during the connection or authentication process.
class AuthService {
  static Future<String?> authenticate({
    required EmailSettingsModel emailSettings,
    required String username,
    required String password,
  }) async {
    final String serverName;
    final int port;
    final String authType = emailSettings.authServerType.toLowerCase();

    if (authType == 'imap') {
      serverName = emailSettings.imapServer;
      port = int.parse(emailSettings.imapPort);
      return await _authenticateImap(
        serverName: serverName,
        port: port,
        username: username,
        password: password,
      );
    } else if (authType == 'smtp') {
      serverName = emailSettings.smtpServer;
      port = int.parse(emailSettings.smtpPort);
      return await _authenticateSmtp(
        serverName: serverName,
        port: port,
        username: username,
        password: password,
      );
    } else {
      return 'Unsupported authentication type';
    }
  }

  static Future<String?> _authenticateImap({
    required String serverName,
    required int port,
    required String username,
    required String password,
  }) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(serverName, port, isSecure: port == 993);
      await client.login(username, password);
      await client.logout();

      return null; // No error message on success
    } on ImapException {
      return 'IMAP Authentication failed: Enter valid username or password';
    } on SocketException {
      return 'SocketException: Invalid server name';
    } on TimeoutException {
      return 'TimeoutException: Connection timed out';
    }
  }

  static Future<String?> _authenticateSmtp({
    required String serverName,
    required int port,
    required String username,
    required String password,
  }) async {
    final client = SmtpClient(serverName, isLogEnabled: false);
    try {
      await client.connectToServer(serverName, port, isSecure: port == 465);
      await client.ehlo();
      await client.authenticate(username, password, AuthMechanism.plain);

      return null; // No error message on success
    } on SmtpException {
      return 'SMTP Authentication failed: Enter valid username or password';
    } on SocketException {
      return 'SocketException: Invalid server name';
    } on TimeoutException {
      return 'TimeoutException: Connection timed out';
    }
  }
}
