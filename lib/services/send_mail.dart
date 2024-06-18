import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:test_drive/services/save_address_to_objbox.dart';

/// the sendEmail method of the class accepts the email components, connects to the SMTP client of iitk,
/// sends ehlo command to the server,builds a MIME message, wraps the body in plain text & html text,
/// spefifies the from ,to and subject field and then send the message to recipient client
/// we give out corresponding messages depending upon the outcome

class EmailSender {
  static Future<void> sendEmail({
    required String username,
    required String password,
    required List<String> to,
    required String subject,
    required String body,
    required Function(String, Color) onResult,
  }) async {
    final client = SmtpClient('enough_mail', isLogEnabled: true);
    try {
      await client.connectToServer('mmtp.iitk.ac.in', 465, isSecure: true);
      await client.ehlo();

      await client.authenticate(username, password, AuthMechanism.plain);

      final builder = MessageBuilder.prepareMultipartAlternativeMessage(
        plainText: body,
        htmlText: "<p>$body</p>",
      )
        ..from = [MailAddress(username, '$username@iitk.ac.in')]
        ..to = to.map((e) => MailAddress(e, e)).toList()
        ..subject = subject;

      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client.sendMessage(mimeMessage);

      if (sendResponse.isOkStatus) {
        saveAddressToDatabase(to);
        onResult('Email sent successfully', Colors.green);
      } else {
        onResult(
            'Failed to send email: Failed to establish connection with server',
            Colors.red);
      }
    } catch (e) {
      onResult('Failed to send email: $e', Colors.red);
    } finally {
      await client.quit();
    }
  }
}
