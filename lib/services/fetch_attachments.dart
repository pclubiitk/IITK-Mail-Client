import 'dart:io';
import 'package:enough_mail/enough_mail.dart';
import 'package:iitk_mail_client/EmailCache/models/attachment.dart';
import 'package:iitk_mail_client/services/email_fetch.dart';

class FetchAttachmentsService {
  static Future<List<Attachment>> fetchAttachments({
    required String username,
    required String password,
    required int uniqueId,
  }) async {
    final List<Attachment> attachments = [];

    try {
      final message = await EmailService.fetchMailByUid(
        uniqueId: uniqueId,
        username: username,
        password: password,
      );

      // Process attachments if any
      if (message.hasAttachments()) {
        for (final part in message.mimeData?.parts ?? []) {
          if (part.isAttachment) {
            // Fetch attachment details
            final content = await part.decodeContentBinary();

            // Construct a download URL (or path) for the attachment
            // Note: You need to implement a mechanism to store the attachment and provide its URL/path.
            final downloadUrl = '/path/to/attachments/${part.filename}';

            // Create an Attachment object with relevant details
            final attachment = Attachment(
              fileName: part.filename ?? 'Unknown',
              size: content.length,
              mimeType:
                  part.contentType?.mimeType ?? 'application/octet-stream',
              downloadUrl: downloadUrl,
            );

            attachments.add(attachment);
          }
        }
      }

      return attachments;
    } on ImapException catch (e) {
      throw Exception("IMAP failed with $e");
    } on SocketException catch (e) {
      throw Exception("Socket exception: $e");
    }
  }
}
