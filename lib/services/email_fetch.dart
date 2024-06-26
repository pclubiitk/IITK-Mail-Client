import 'package:enough_mail/enough_mail.dart';
import "package:iitk_mail_client/EmailCache/cache_service.dart";
import "../EmailCache/objectbox.dart";
import "./save_mails_to_objbox.dart";
import "../EmailCache/initializeobjectbox.dart";
import "../EmailCache/models/email.dart";
import "../objectbox.g.dart";
import '../models/advanced_settings_model.dart';

/// the method defined in the class logs in to the IMAP client of iitk
/// after log in we choose inbox folder from the server
/// the fetchRecentMessages method fetches 50(hardcoded) most recent messages from the inbox folder
/// we reverse the mails to order them chronologically

class EmailService {
  static Future<void> fetchEmails({
    required EmailSettingsModel emailSettings,
    required String username,
    required String password,
  }) async {
    final String serverName = emailSettings.imapServer;
    final int port = int.parse(emailSettings.imapPort);
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(serverName, port, isSecure: port == 993);
      await client.login(username, password);
      await client.selectInbox();
      final fetchMessages = await client.fetchRecentMessages(
          messageCount: 20, criteria: "(UID BODY.PEEK[])");
      await saveEmailsToDatabase(fetchMessages.messages);
      await client.logout();
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }

  static Future<void> fetchNewEmails({
    required EmailSettingsModel emailSettings,
    required String username,
    required String password,
  }) async {
    final String serverName = emailSettings.imapServer;
    final int port = int.parse(emailSettings.imapPort);
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(serverName, port, isSecure: port == 993);
      await client.login(username, password);
      await client.selectInbox();
      List<MimeMessage> allFetchedMessages = [];
      int? highestUid = getHighestUidFromDatabase();
      int fetchuid = highestUid + 1;

      final fetchResult = await client
          .uidFetchMessagesByCriteria("$fetchuid:* (UID BODY.PEEK[])");

      if (fetchResult.messages.length == 1) {
        if (fetchResult.messages[0].uid != highestUid) {
          allFetchedMessages.addAll(fetchResult.messages);
        }
      } else {
        allFetchedMessages.addAll(fetchResult.messages);
      }
      if (allFetchedMessages.isNotEmpty) {
        await UpdateDatabase(allFetchedMessages);
      } else {
        logger.i("No new mails recieved");
      }
      await client.logout();
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }

  static Future<MimeMessage> fetchMailByUid({
    required int uniqueId,
    required String username,
    required String password,
  }) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer('qasid.iitk.ac.in', 993, isSecure: true);
      await client.login(username, password);
      await client.selectInbox();
      final imapResult = await client.uidFetchMessage(uniqueId, 'BODY[]');
      await client.logout();
      return imapResult.messages[0];
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }
}
