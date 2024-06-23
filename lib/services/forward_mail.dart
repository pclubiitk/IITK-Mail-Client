import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:iitk_mail_client/EmailCache/models/email.dart';

class EmailForward {
  static Future<void> forwardEmail({
    required String username,
    required String password,
    required Email originalMessage,
    required String forwardTo,
    required String forwardBody,
    required Function(String, Color) onResult,
  }) async {
    final client = SmtpClient('enough_mail', isLogEnabled: true);
    try {
      await client.connectToServer('mmtp.iitk.ac.in', 465, isSecure: true);
      await client.ehlo();

      await client.authenticate(username, password, AuthMechanism.plain);

      // final originalPlainText = originalMessage.decodeTextPlainPart() ?? '';
      // final originalHtmlText = originalMessage.decodeTextHtmlPart() ?? '';
      final originalPlainText = originalMessage.body ?? '';
      final originalHtmlText = originalMessage.body ?? '';
      final forwardText = '\n\nForwarded message:\n\n$originalPlainText';
      final fullForwardBody = '$forwardBody\n$forwardText';

      final builder = MessageBuilder.prepareMultipartAlternativeMessage(
        plainText: fullForwardBody,
        htmlText: "<p>$forwardBody</p><blockquote>$originalHtmlText</blockquote>",
      )
        ..from = [MailAddress(username, '$username@iitk.ac.in')]
        ..to = [MailAddress(forwardTo, forwardTo)]
        ..subject = 'Fwd: ${originalMessage.subject}';

      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client.sendMessage(mimeMessage);

      if (sendResponse.isOkStatus) {
        onResult('Email forwarded successfully', Colors.green);
      } else {
        onResult('Failed to forward email: Failed to establish connection with server', Colors.red);
      }
    } catch (e) {
      onResult('Failed to forward email: $e', Colors.red);
    } finally {
      await client.quit();
    }
  }
}
