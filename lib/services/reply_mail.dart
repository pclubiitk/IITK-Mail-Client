import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:iitk_mail_client/EmailCache/models/email.dart';
import 'package:iitk_mail_client/services/email_fetch.dart';
import 'package:iitk_mail_client/services/save_mails_to_objbox.dart';

class EmailReply {
  static Future<void> replyEmail({
    required String username,
    required String password,
    required Email originalMessage,
    required String replyBody,
    required Function(String, Color) onResult,
  }) async {
    logger.i('Starting replyEmail function');
    final client = SmtpClient('enough_mail', isLogEnabled: false);
    try {
      await client.connectToServer('mmtp.iitk.ac.in', 465, isSecure: true);
      await client.ehlo();
      logger.i('Connected and authenticated');

      await client.authenticate(username, password, AuthMechanism.plain);
      // logger.i("email $username" );
      MimeMessage originalMimeMessage = await EmailService.fetchMailByUid(
          uniqueId: int.parse(originalMessage.uniqueId.toString()),
          username: username,
          password: password);
      logger.i(originalMimeMessage);
      final builder = MessageBuilder.prepareReplyToMessage(
        originalMimeMessage,
        MailAddress(username, '$username@iitk.ac.in'),
      );
      final originalBody = originalMessage.body;
      final newBody = "$replyBody\n\n----Original Message----\n\n$originalBody";

      // Combine reply body with the quoted original message
      builder.text = newBody;

      logger.i('Combined Body:\n${builder.text}');
      //builder.text=replyBody;

      final mimeMessage = builder.buildMimeMessage();

      logger.i(mimeMessage.decodeTextPlainPart());

      final sendResponse = await client.sendMessage(mimeMessage);

      if (sendResponse.isOkStatus) {
        onResult('Reply sent successfully', Colors.green);
      } else {
        onResult(
            'Failed to send reply: Failed to establish connection with server',
            Colors.red);
      }
    } catch (e) {
      onResult('Failed to send reply: $e', Colors.red);
      logger.e('Error: $e');
      logger.i(e);
    } finally {
      await client.quit();
    }
  }
}
