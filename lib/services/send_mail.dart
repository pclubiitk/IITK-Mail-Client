import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import '../models/advanced_settings_model.dart';

/// the sendEmail method of the class accepts the email components, connects to the SMTP client of iitk,
/// sends ehlo command to the server,builds a MIME message, wraps the body in plain text & html text, 
/// spefifies the from ,to and subject field and then send the message to recipient client
/// we give out corresponding messages depending upon the outcome

class EmailSender {
  static Future<void> sendEmail({
    required String username,
    required String password,
    required String to,
    required String subject,
    required String body,
    required Function(String, Color) onResult,
    required EmailSettingsModel emailSettings,
  }) async {
    final String serverName=emailSettings.smtpServer;
    final int port=int.parse(emailSettings.smtpPort);
    final String domainName=emailSettings.domain;
    
    final client = SmtpClient('enough_mail', isLogEnabled: true);
    try {
      await client.connectToServer(serverName, port, isSecure: port == 465);
      await client.ehlo();

      await client.authenticate(username, password, AuthMechanism.plain);

      final builder = MessageBuilder.prepareMultipartAlternativeMessage(
        plainText: body,
        htmlText: "<p>$body</p>",
      )
        ..from = [MailAddress(username, '$username@$domainName')]
        ..to = [MailAddress(to, to)]
        ..subject = subject;

      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client.sendMessage(mimeMessage);

      if (sendResponse.isOkStatus) {
        onResult('Email sent successfully', Colors.green);
      } else {
        onResult('Failed to send email: Failed to establish connection with server', Colors.red);
      }
    } catch (e) {
      onResult('Failed to send email: $e', Colors.red);
    } finally {
      await client.quit();
    }
  }
}
