import 'package:enough_mail/enough_mail.dart';
import "../EmailCache/objectbox.dart";
import "./save_mails_to_objbox.dart";
import "../EmailCache/initializeobjectbox.dart";
import "../EmailCache/models/email.dart";
import "../objectbox.g.dart";

/// the method defined in the class logs in to the IMAP client of iitk
/// after log in we choose inbox folder from the server
/// the fetchRecentMessages method fetches 50(hardcoded) most recent messages from the inbox folder
/// we reverse the mails to order them chronologically

class EmailService {
  static Future<void> fetchEmails({
    required String username,
    required String password,
  }) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer('qasid.iitk.ac.in', 993, isSecure: true);
      await client.login(username, password);
      await client.selectInbox();
      final fetchMessages = await client.fetchRecentMessages(
          messageCount: 15, criteria: 'BODY.PEEK[]');
      await saveEmailsToDatabase(fetchMessages.messages.reversed.toList());
      await client.logout();
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }

  static Future<void> fetchNewEmails({
    required String username,
    required String password,
  }) async {
    final client = ImapClient(isLogEnabled: false);
    try{
      await client.connectToServer('qasid.iitk.ac.in', 993, isSecure: true);
      await client.login(username, password);
      await client.selectInbox();
      final upperSequenceId = objectbox.emailBox.getAll().last.uniqueId - 1;
      var lowerSequenceId = upperSequenceId - 30;
      if(lowerSequenceId < 1){
        lowerSequenceId = 1;
      }
      final fetchMessages = await client.fetchMessages(MessageSequence.fromRange(lowerSequenceId, upperSequenceId), "(FLAGS BODY[])");
      await UpdateDatabase(fetchMessages.messages.reversed.toList());
      await client.logout();
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }
}
