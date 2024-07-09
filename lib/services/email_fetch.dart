import 'package:enough_mail/enough_mail.dart';
import "package:iitk_mail_client/Storage/queries/highest_uid.dart";
import "package:iitk_mail_client/Storage/queries/lowest_sequence_number.dart";
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
      try{
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
        criteria: "(UID FLAGS BODY.PEEK[TEXT] BODY.PEEK[HEADER.FIELDS (FROM TO SUBJECT DATE)])"
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

      final fetchResult = await client.uidFetchMessagesByCriteria("$fetchuid:* (UID FLAGS BODYSTRUCTURE BODY.PEEK[HEADER.FIELDS (FROM TO SUBJECT DATE)] BODY.PEEK[TEXT])");

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
    final String serverName = emailSettings.imapServer;
    final int port = int.parse(emailSettings.imapPort);
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(serverName, port, isSecure: port == 993);
      await client.login(username, password);
      await client.selectInbox();
      List<MimeMessage> allFetchedMessages = [];

      int? oldestSequenceNumber = getOldestSequenceNumberFromDatabase();

      logger.i("the oldest sequence numbers are : $oldestSequenceNumber");

      int fetchCount = 10;
      int startSequenceNumber = max(1, oldestSequenceNumber - fetchCount);
      
      final fetchResult = await client.fetchMessagesByCriteria(
        // MessageSequence.fromRange(startSequenceNumber,oldestSequenceNumber - 1,isUidSequence: false)
        // ,
        // "BODY.PEEK[]"
        "UID FLAGS BODY.PEEK[HEADER.FIELDS (FROM TO SUBJECT DATE)] BODY.PEEK[TEXT]",
      );

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
      await client.connectToServer('qasid.iitk.ac.in', 993, isSecure: true);
      await client.login(username, password);
      await client.selectInbox();
      final imapResult = await client.uidFetchMessage(uniqueId,'BODY[]');
      final sequence = MessageSequence.fromId(uniqueId);
      await client.markSeen(sequence);
      await client.logout();
      return imapResult.messages[0];
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    }
  }
}




// import 'package:enough_mail/enough_mail.dart';
// import "package:iitk_mail_client/EmailCache/cache_service.dart";
// import "package:iitk_mail_client/EmailCache/initializeobjectbox.dart";
// import "package:logger/logger.dart";
// import "./save_mails_to_objbox.dart";
// import "../EmailCache/models/email.dart";
// import "../EmailCache/models/attachment.dart";
// import "../objectbox.g.dart";
// import '../models/advanced_settings_model.dart';

// final logger = Logger();

// class EmailService {
//   static Future<void> fetchInitialEmails({
//     required EmailSettingsModel emailSettings,
//     required String username,
//     required String password,
//   }) async {
//     final String serverName = emailSettings.imapServer;
//     final int port = int.parse(emailSettings.imapPort);
//     final client = ImapClient(isLogEnabled: false);
//     try {
//       await client.connectToServer(serverName, port, isSecure: port == 993);
//       await client.login(username, password);
//       await client.selectInbox();
//       final fetchMessages = await client.fetchRecentMessages(
//         messageCount: 100,
//         criteria: "(UID FLAGS BODY.PEEK[HEADER.FIELDS (FROM SUBJECT DATE)] BODY.PEEK[TEXT])"
//       );
//       await saveEmailsToDatabase(fetchMessages.messages);
//       await client.logout();
//     } on ImapException catch (e) {
//       throw Exception("IMAP failed with $e");
//     }
//   }

//   static Future<void> fetchNewEmails({
//     required EmailSettingsModel emailSettings,
//     required String username,
//     required String password,
//   }) async {
//     final String serverName = emailSettings.imapServer;
//     final int port = int.parse(emailSettings.imapPort);
//     final client = ImapClient(isLogEnabled: false);
//     try {
//       await client.connectToServer(serverName, port, isSecure: port == 993);
//       await client.login(username, password);
//       await client.selectInbox();
//       int? highestUid = getHighestUidFromDatabase();
//       int fetchUid = highestUid + 1;

//       final fetchResult = await client.uidFetchMessagesByCriteria(
//         "$fetchUid:* (UID FLAGS BODY.PEEK[HEADER.FIELDS (FROM SUBJECT DATE)] BODY.PEEK[TEXT])"
//       );

//       if (fetchResult.messages.isNotEmpty) {
//         await updateDatabase(fetchResult.messages);
//       }
//       await client.logout();
//     } on ImapException catch (e) {
//       throw Exception("IMAP failed with $e");
//     }
//   }

//   static Future<MimeMessage> fetchMailByUid({
//     required int uniqueId,
//     required String username,
//     required String password,
//     required EmailSettingsModel emailSettings,
//   }) async {
//     final String serverName = emailSettings.imapServer;
//     final int port = int.parse(emailSettings.imapPort);
//     final client = ImapClient(isLogEnabled: false);
//     try {
//       await client.connectToServer(serverName, port, isSecure: port == 993);
//       await client.login(username, password);
//       await client.selectInbox();
//       final imapResult = await client.uidFetchMessage(uniqueId, 'BODY[]');
//       await client.logout();
//       return imapResult.messages[0];
//     } on ImapException catch (e) {
//       throw Exception("IMAP failed with $e");
//     }
//   }

//   static Future<void> markEmailAsRead({
//     required int uniqueId,
//     required String username,
//     required String password,
//     required EmailSettingsModel emailSettings,
//   }) async {
//     final String serverName = emailSettings.imapServer;
//     final int port = int.parse(emailSettings.imapPort);
//     final client = ImapClient(isLogEnabled: false);
//     try {
//       await client.connectToServer(serverName, port, isSecure: port == 993);
//       await client.login(username, password);
//       await client.selectInbox();
//       await client.uidStore(MessageSequence.fromId(uniqueId), [MessageFlags.seen]);
//       await client.logout();

//       // Update local database
//       final email = objectbox.emailBox.query(Email_.uniqueId.equals(uniqueId)).build().findFirst();
//       if (email != null) {
//         email.isRead = true;
//         objectbox.emailBox.put(email);
//       }
//     } on ImapException catch (e) {
//       throw Exception("IMAP failed with $e");
//     }
//   }

//   static Future<List<Attachment>> fetchAttachments({
//     required int uniqueId,
//     required String username,
//     required String password,
//     required EmailSettingsModel emailSettings,
//   }) async {
//     final mimeMessage = await fetchMailByUid(
//       uniqueId: uniqueId,
//       username: username,
//       password: password,
//       emailSettings: emailSettings,
//     );

//     List<Attachment> attachments = [];
//     for (var part in mimeMessage.allPartsFlat) {
//       if (part.dispositionType?.disposition == ContentDispositionHeader.ATTACHMENT) {
//         final fileName = part.decodeFileName() ?? 'unknown';
//         final contentType = part.contentType?.mimeType ?? 'application/octet-stream';
//         final size = part.size ?? 0;
//         final data = part.decodeContentBinary();

//         attachments.add(Attachment(
//           fileName: fileName,
//           contentType: contentType,
//           size: size,
//           data: data,
//         ));
//       }
//     }

//     // Save attachments to the database
//     final email = objectbox.emailBox.query(Email_.uniqueId.equals(uniqueId)).build().findFirst();
//     if (email != null) {
//       email.attachments.addAll(attachments);
//       objectbox.emailBox.put(email);
//     }

//     return attachments;
//   }
// }