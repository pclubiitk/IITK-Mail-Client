import 'package:enough_mail/enough_mail.dart';
import 'package:iitk_mail_client/Storage/models/email.dart';
import '../models/advanced_settings_model.dart';

class SentEmailService {
  static Future<List<Email>> fetchSentEmails({
    required EmailSettingsModel emailSettings,
    required String username,
    required String password,
  }) async {
    final String serverName = emailSettings.imapServer;
    final int port = int.parse(emailSettings.imapPort);
    final client = ImapClient(isLogEnabled: false);
    final List<Email> sentEmails = [];

    try {
      await client.connectToServer(serverName, port, isSecure: port == 993);
      await client.login(username, password);
      final mailboxPath = 'INBOX.Sent';
      await client.selectMailboxByPath(mailboxPath);
      final fetchMessages = await client.fetchRecentMessages(
          messageCount: 50, criteria: 'BODY.PEEK[]');

      for (final sentMessage in fetchMessages.messages.reversed.toList()) {
        String? body;
        String? plainText = sentMessage.decodeTextPlainPart();
        String? htmlText = sentMessage.decodeTextHtmlPart();

        if (plainText != null && plainText.isNotEmpty) {
          body = plainText;
        } else if (htmlText != null && htmlText.isNotEmpty) {
          body = htmlText;
        } else {
          body = 'No Text Body';
        }
        String? personalName = sentMessage.from!.first.personalName;
          String? senderEmail = sentMessage.from!.first.email;
          String sender = personalName ?? senderEmail;

         final email = Email(
          senderName: sender,
          from: sentMessage.from?.isNotEmpty == true ? sentMessage.from!.first.email : 'Unknown',
          to: sentMessage.to?.isNotEmpty == true ? sentMessage.to!.first.email : 'Unknown',
          subject: sentMessage.decodeSubject() ?? 'No Subject',
          body: body,
          receivedDate: sentMessage.decodeDate() ?? DateTime.now(),
          uniqueId: sentMessage.uid!,
          hasAttachment: false,
          isRead: true,
          isFlagged: false,
          isTrashed: false,
        );
        sentEmails.add(email);
      }
      await client.logout();
      return sentEmails;
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }
}
