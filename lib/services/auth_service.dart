import 'package:enough_mail/enough_mail.dart';
import 'dart:io';
import 'dart:async';
import '../models/advanced_settings_model.dart';

/// The authenticate method of AuthService verifies the credentials
/// Throws the respective errors during the connection or authentication process.
/// It uses either IMAP or SMTP to authenticate based on preference in advanced settings
/// By default, it uses IMAP secure server to login
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
      await client.connectToServer(serverName, port,
          isSecure: port ==
              993); //if port name is 993 then isSecure=True otherwise false
      await client.login(username, password);
      await client.logout();
      print("Imap Login");

      return null; // No error message on success
    } on ImapException {
      return 'IMAP Authentication failed: Enter valid username or password'; //When credentials are incorrect
    } on SocketException {
      return 'Invalid server name'; //When server name is incorrect
    } on TimeoutException {
      return 'Incorrect Port Name'; //When port name is incorrect
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
      print("SMTP login");

      return null; // No error message on success
    } on SmtpException {
      return 'SMTP Authentication failed: Enter valid username or password';
    } on SocketException {
      return 'Invalid server name';
    } on TimeoutException {
      return 'Incorrect Port Name';
    }
  }
}
