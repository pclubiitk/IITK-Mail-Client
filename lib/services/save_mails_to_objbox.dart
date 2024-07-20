import 'package:enough_mail/enough_mail.dart';
import 'package:logger/logger.dart';
import 'package:iitk_mail_client/Storage/initializeobjectbox.dart';
import 'package:enough_mail_html/enough_mail_html.dart';
import '../Storage/models/email.dart'; // Ensure correct import for Email model
import 'package:html/parser.dart' show parse; 

final logger = Logger();

Future<void> saveEmailsToDatabase(List<MimeMessage> messages) async {
  try {
    /// Clear existing emails
    objectbox.emailBox.removeAll();
    logger.i('All previous emails removed from the database.');

    /// Iterate over each message and save to database
    for (final message in messages) {
      try {
        // // Decode the body content
        // String? body = message.decodeTextPlainPart();
        // if (body == null || body.isEmpty) {
        //   // Fallback to HTML content if plain text is not available
        //   String? htmlBody = message.decodeTextHtmlPart();
        //   if (htmlBody != null && htmlBody.isNotEmpty) {
        //     body = HtmlToPlainTextConverter.convert(htmlBody);
        //     //body = parse(htmlBody).documentElement!.text;  // Convert HTML to plain text
        //   } else {
        //     body = 'No Text Body';
        //   }
        // }
        //String body = message.decodeTextPlainPart() ?? message.decodeTextHtmlPart() ?? 'No Text Body';
        // String? body = message.decodeContentText();
        // body??="No body";
        String? body;
        String? plainText = message.decodeTextPlainPart();
        String? htmlText = message.decodeTextHtmlPart();

        // /// Determine the body content
        if (htmlText != null) {
          body = htmlText;
          logger.i("html");
        }
        else if (plainText != null && plainText.isNotEmpty) {
          body = plainText;
          logger.i("plain text");
        } 
        else {
          body = 'No Text Body';
        }
        String? personalName = message.from!.first.personalName;
        String? senderEmail = message.from!.first.email;
        String sender = personalName ?? senderEmail;

        bool hasAttachments = message.hasAttachments();

        /// Create Email object
         
         final email = Email(
          from: message.from?.isNotEmpty == true
              ? message.from!.first.email
              : 'Unknown',
          to: message.to?.isNotEmpty == true
              ? message.to!.first.email
              : 'Unknown',
          subject: message.decodeSubject() ?? 'No Subject',
          body: body,
          receivedDate: message.decodeDate() ?? DateTime.now(),
          uniqueId: message.uid!,
          senderName: sender,
          hasAttachment: hasAttachments,
          isRead: message.flags!.contains(MessageFlags.seen),
          isFlagged: message.isFlagged,
          isTrashed: message.isDeleted,
        );

        /// Save Email object to the database
        objectbox.emailBox.put(email);
        logger.i('Email from ${email.from} saved successfully\nisRead: ${email.isRead}\thasAttachment: ${email.hasAttachment}\t isFlagged: ${email.isFlagged}\tisTrasshed: ${email.isTrashed} ');
      } catch (e) {
        logger.e('Failed to save email: ${e.toString()}');
      }
    }
  } catch (e) {
    logger.e('Error during saving emails to database: ${e.toString()}');
  }
}

Future<void> updateDatabase(List<MimeMessage> messages) async {
  try {
    /// Iterate over each message and save to database
    for (final message in messages) {
      try {
        String? body;
        String? plainText = message.decodeTextPlainPart();
        String? htmlText = message.decodeTextHtmlPart();

        /// Determine the body content
         if (htmlText != null) {
          body = htmlText;
          logger.i("html");
        }
        else if (plainText != null && plainText.isNotEmpty) {
          body = plainText;
          logger.i("plain text");
        } 
        else {
          body = 'No Text Body';
        }
        String? personalName = message.from!.first.personalName;
        String? senderEmail = message.from!.first.email;
        String sender = personalName ?? senderEmail;
        bool hasAttachments = message.hasAttachments();

        /// Create Email object
        final email = Email(
          from: message.from?.isNotEmpty == true
              ? message.from!.first.email
              : 'Unknown',
          to: message.to?.isNotEmpty == true
              ? message.to!.first.email
              : 'Unknown',
          subject: message.decodeSubject() ?? 'No Subject',
          body: body,
          receivedDate: message.decodeDate() ?? DateTime.now(),
          uniqueId: message.uid!,
          senderName: sender,
          hasAttachment: hasAttachments,
          isRead: message.flags!.contains(MessageFlags.seen),
          isFlagged: false,
          isTrashed: false,
        );

        /// Save Email object to the database
        objectbox.emailBox.put(email);
        logger.i('Email from ${email.from} to ${email.to} saved successfully.');
      } catch (e) {
        logger.e('Failed to save email: ${e.toString()}');
      }
    }
  } catch (e) {
    logger.e('Error during saving emails to database: ${e.toString()}');
  }
}
