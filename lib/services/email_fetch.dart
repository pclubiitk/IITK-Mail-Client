import 'package:enough_mail/enough_mail.dart';
import '../models/advanced_settings_model.dart';

/// the method defined in the class logs in to the IMAP client of iitk
/// after log in we choose inbox folder from the server
/// the fetchRecentMessages method fetches 50(hardcoded) most recent messages from the inbox folder
/// we reverse the mails to order them chronologically

class EmailService {
  static Future<List<MimeMessage>> fetchEmails({
    required EmailSettingsModel emailSettings,
    required String username,
    required String password,
  }) async {
    final String serverName=emailSettings.imapServer;
    final int port=int.parse(emailSettings.imapPort);
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(serverName, port, isSecure: port == 993);
      await client.login(username, password);
      await client.selectInbox();
      final fetchMessages = await client.fetchRecentMessages(messageCount: 15, criteria: 'BODY.PEEK[]');
      await client.logout();
      return fetchMessages.messages.reversed.toList();
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }
}
