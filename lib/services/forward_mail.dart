import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:iitk_mail_client/EmailCache/models/email.dart';
import 'package:iitk_mail_client/models/advanced_settings_model.dart';
import 'package:iitk_mail_client/services/email_fetch.dart';

class EmailForward {
  static Future<void> forwardEmail({
    required EmailSettingsModel emailSettings,
    required String username,
    required String password,
    required Email originalMessage,
    required String forwardTo,
    required String forwardBody,
    required Function(String, Color) onResult,
  }) async {
    final String serverName = emailSettings.smtpServer;
    final int port = int.parse(emailSettings.smtpPort); 
    final client = SmtpClient('enough_mail', isLogEnabled: true);
    try {
      await client.connectToServer(serverName, port, isSecure: port == 465);
      await client.ehlo();

      await client.authenticate(username, password, AuthMechanism.plain);
      final forwardSubject = 'Fwd: ${originalMessage.subject}';
      MimeMessage originalMimeMessage = await EmailService.fetchMailByUid(
          uniqueId: int.parse(originalMessage.uniqueId.toString()),
          username: username,
          password: password);

      final builder = MessageBuilder.prepareForwardMessage(
        originalMimeMessage,
        from: MailAddress(username, '$username@${emailSettings.domain}'),
        forwardHeaderTemplate: 'Forwarded message',
        // quoteMessage: true,
        // subjectEncoding: HeaderEncoding.Q,
        // forwardAttachments: true,
      );
      final originalBody = originalMessage.body;
      final newBody =
          "$forwardBody\n\n----Original Message----\n\n$originalBody";

      /// Combine reply body with the quoted original message
      builder.text = newBody;
      builder.to = [MailAddress(null, forwardTo)];
      builder.subject = forwardSubject;
      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client.sendMessage(mimeMessage);

      if (sendResponse.isOkStatus) {
        onResult('Email forwarded successfully', Colors.green);
      } else {
        onResult(
            'Failed to forward email: Failed to establish connection with server',
            Colors.red);
      }
    } catch (e) {
      onResult('Failed to forward email: $e', Colors.red);
    } finally {
      await client.quit();
    }
  }
}
