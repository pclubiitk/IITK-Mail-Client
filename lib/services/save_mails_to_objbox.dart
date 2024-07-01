import 'package:enough_mail/enough_mail.dart';
import 'package:logger/logger.dart';

import 'package:iitk_mail_client/EmailCache/initializeobjectbox.dart';
import '../EmailCache/models/email.dart'; // Ensure correct import for Email model

final logger = Logger();

Future<void> saveEmailsToDatabase(List<MimeMessage> messages) async {
  try {
    /// Clear existing emails
    objectbox.emailBox.removeAll();
    logger.i('All previous emails removed from the database.');

    /// Iterate over each message and save to database
    for (final message in messages) {
      try {
        String? body;
        String? plainText = message.decodeTextPlainPart();
        String? htmlText = message.decodeTextHtmlPart();

        /// Determine the body content
        if (plainText != null && plainText.isNotEmpty) {
          body = plainText;
        } else if (htmlText != null && htmlText.isNotEmpty) {
          body = htmlText;
        } else {
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
          uniqueId: message.uid!, // Add unique ID logic if needed
          senderName: sender,
          hasAttachment: hasAttachments,
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

Future<void> UpdateDatabase(List<MimeMessage> messages) async {
  try {
    /// Iterate over each message and save to database
    for (final message in messages) {
      try {
        String? body;
        String? plainText = message.decodeTextPlainPart();
        String? htmlText = message.decodeTextHtmlPart();

        /// Determine the body content
        if (plainText != null && plainText.isNotEmpty) {
          body = plainText;
        } else if (htmlText != null && htmlText.isNotEmpty) {
          body = htmlText;
        } else {
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
          uniqueId: message.uid!, // Add unique ID logic if needed
          senderName: sender,
          hasAttachment: hasAttachments,
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
