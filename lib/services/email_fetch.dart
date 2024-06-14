import 'package:enough_mail/enough_mail.dart';

class EmailService {
  static Future<List<MimeMessage>> fetchEmails({
    required String username,
    required String password,
    required String server,
    required bool isSecure, // Added isSecure parameter
  }) async {
    final client = ImapClient(isLogEnabled: false);
    final int port = isSecure ? 993 : 143; // Select port based on isSecure
    try {
      await client.connectToServer('qasid.$server', port, isSecure: isSecure);
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
