import 'package:enough_mail/enough_mail.dart';
import "package:iitk_mail_client/Storage/queries/highest_uid.dart";
import "package:iitk_mail_client/Storage/queries/lowest_uid.dart";
import "package:logger/logger.dart";
import "./save_mails_to_objbox.dart";
import '../models/advanced_settings_model.dart';
import 'dart:math';



/// the method defined in the class logs in to the IMAP client of iitk
/// after log in we choose inbox folder from the server
/// the fetchRecentMessages method fetches 50(hardcoded) most recent messages from the inbox folder
/// we reverse the mails to order them chronologically

final logger = Logger();

class ImapService {

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
      try{
        logger.i("Lisitng mail boxes");
        final mailboxes = await client.listMailboxes();
        for (final mailbox in mailboxes) {
          logger.i('Folder: ${mailbox.name}');
        }
      }
      catch (e) {
        logger.i("error in finding the user folders with error\n$e ");
      }
      await client.selectInbox();
      final fetchMessages = await client.fetchRecentMessages(
        messageCount: 40, 
        //criteria: "(UID FLAGS BODYSTRUCTURE BODY.PEEK[HEADER.FIELDS (FROM TO SUBJECT DATE)] BODY.PEEK[TEXT])"
        criteria: "(UID FLAGS BODY.PEEK[])"
      );
      // var messages = fetchMessages.messages;
      // messages = messages.reversed.toList();
      // for(final message in messages){
      //   logger.i("UID: ${message.uid}\nFlags: ${message.flags}");
      // }
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

      final fetchResult = await client.uidFetchMessagesByCriteria("$fetchuid:* (UID FLAGS BODY.PEEK[])");

      if (fetchResult.messages.length == 1) {
        if (fetchResult.messages[0].uid != highestUid) {
          allFetchedMessages.addAll(fetchResult.messages);
        }
      } else {
        allFetchedMessages.addAll(fetchResult.messages);
      }
      if (allFetchedMessages.isNotEmpty) {
        await updateDatabase(allFetchedMessages);
      } else {
        logger.i("No new mails recieved");
      }
      await client.logout();
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }

  static Future<void> fetchOlderEmails({
    required EmailSettingsModel emailSettings,
    required String username,
    required String password,
  }) async {
    logger.i("at fetch older mails");
    final String serverName = emailSettings.imapServer;
    final int port = int.parse(emailSettings.imapPort);
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(serverName, port, isSecure: port == 993);
      await client.login(username, password);
      await client.selectInbox();
      List<MimeMessage> allFetchedMessages = [];

      final oldestUID = getLowestUidFromDatabase();
      //final sequnceIDverifier = getOldestSequenceNumberFromDatabase();

      final fetchMessageForSequenceId = await client.uidFetchMessage(oldestUID, "(UID)");

      final seqId = fetchMessageForSequenceId.messages[0].sequenceId;

      //logger.i("in db: $sequnceIDverifier\nfrom Imap: $seqId ");

      int fetchCount = 10;
      int startSequenceNumber = max(1, seqId! - fetchCount);

      final fetchResult = await client.fetchMessagesByCriteria("$startSequenceNumber:${startSequenceNumber+fetchCount-1} (UID FLAGS BODY.PEEK[])");
      
      // final fetchResult = await client.fetchMessages(
      //   MessageSequence.fromRange(startSequenceNumber,oldestSequenceNumber - 1,isUidSequence: false)
      //   ,
      //   "BODY.PEEK[]"
      //   //"UID FLAGS BODY.PEEK[HEADER.FIELDS (FROM TO SUBJECT DATE)] BODY.PEEK[TEXT]",
      // );

       allFetchedMessages.addAll(fetchResult.messages);

       if (allFetchedMessages.isNotEmpty) {
        await updateDatabase(allFetchedMessages);
      } 
      else {
        logger.i("All mails have been fetched");
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
      logger.i("UID : $uniqueId");
      await client.connectToServer('qasid.iitk.ac.in', 993, isSecure: true);
      await client.login(username, password);
      await client.selectInbox();
      final imapResult = await client.uidFetchMessage(uniqueId,'BODY[]');
      // final sequence = MessageSequence.fromId(uniqueId);
      // await client.markSeen(sequence);
      await client.logout();
      return imapResult.messages[0];
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }

  static Future<void> toggleFlagged({
    required bool isFlagged,
    required int uniqueId,
    required String username,
    required String password,
    }) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      logger.i("UID : $uniqueId");
      await client.connectToServer('qasid.iitk.ac.in', 993, isSecure: true);
      await client.login(username, password);
      await client.selectInbox();
      
      final sequence = MessageSequence.fromId(uniqueId, isUid: true);
      if(isFlagged==false){
      await client.uidMarkFlagged(sequence);
      logger.i("flagged");
      }
      else {
       await client.uidMarkUnflagged(sequence);
       logger.i("unflagged");
      }
      await client.logout();
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }
  static Future<void> toggleTrashed({
    required bool isTrashed,
    required int uniqueId,
    required String username,
    required String password,
    }) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      logger.i("UID : $uniqueId");
      await client.connectToServer('qasid.iitk.ac.in', 993, isSecure: true);
      await client.login(username, password);
      await client.selectInbox();
      
      final sequence = MessageSequence.fromId(uniqueId, isUid: true);
      if(isTrashed==false){
      await client.uidMarkDeleted(sequence);
      logger.i("deleted");
      }
      else {
       await client.uidMarkUndeleted(sequence);
       logger.i("undeleted");
      }
      await client.logout();
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }
    static Future<void> markRead({
    required int uniqueId,
    required String username,
    required String password,
    }) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      logger.i("UID : $uniqueId");
      await client.connectToServer('qasid.iitk.ac.in', 993, isSecure: true);
      await client.login(username, password);
      await client.selectInbox();
      
      final sequence = MessageSequence.fromId(uniqueId, isUid: true);

      await client.uidMarkSeen(sequence);
      logger.i("email is if $uniqueId has been marked read");
      await client.logout();
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }
}
