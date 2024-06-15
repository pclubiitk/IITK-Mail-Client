import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';

class EmailReply {
  static Future<void> replyEmail({
    required String username,
    required String password,
    required MimeMessage originalMessage,
    required String replyBody,
    required Function(String, Color) onResult,
  }) async {
    final client = SmtpClient('enough_mail', isLogEnabled: true);
    try {
      await client.connectToServer('mmtp.iitk.ac.in', 465, isSecure: true);
      await client.ehlo();

      await client.authenticate(username, password, AuthMechanism.plain);

      final originalPlainText = originalMessage.decodeTextPlainPart() ?? '';
      final originalHtmlText = originalMessage.decodeTextHtmlPart() ?? '';
      final replyText = '\n\nOn ${originalMessage.decodeDate()} ${originalMessage.decodeSender()} wrote:\n\n$originalPlainText';
      final fullReplyBody = '$replyBody\n$replyText';

      final builder = MessageBuilder.prepareMultipartAlternativeMessage(
        plainText: fullReplyBody,
        htmlText: "<p>$replyBody</p><blockquote>$originalHtmlText</blockquote>",
      )
        ..from = [MailAddress(username, '$username@iitk.ac.in')]
        ..to = originalMessage.from?.toList()
        ..subject = 'Re: ${originalMessage.decodeSubject()}';

      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client.sendMessage(mimeMessage);

      if (sendResponse.isOkStatus) {
        onResult('Reply sent successfully', Colors.green);
      } else {
        onResult('Failed to send reply: Failed to establish connection with server', Colors.red);
      }
    } catch (e) {
      onResult('Failed to send reply: $e', Colors.red);
    } finally {
      await client.quit();
    }
  }
}
