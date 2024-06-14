import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';

class EmailSender {
  static Future<void> sendEmail({
    required String username,
    required String password,
    required String server,
    required bool isSecure, // Added isSecure parameter
    required String to,
    required String subject,
    required String body,
    required Function(String, Color) onResult,
  }) async {
    final client = SmtpClient('enough_mail', isLogEnabled: true);
    final int port = isSecure ? 465 : 25; // Select port based on isSecure
    try {
      await client.connectToServer('mmtp.$server', port, isSecure: isSecure);
      await client.ehlo();

      await client.authenticate(username, password, AuthMechanism.plain);

      final builder = MessageBuilder.prepareMultipartAlternativeMessage(
        plainText: body,
        htmlText: "<p>$body</p>",
      )
        ..from = [MailAddress(username, '$username@$server')]
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
