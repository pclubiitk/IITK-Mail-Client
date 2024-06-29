import 'package:enough_mail/enough_mail.dart';
import 'package:iitk_mail_client/EmailCache/models/message.dart';
import 'package:iitk_mail_client/pages/email_list.dart';
import 'package:iitk_mail_client/services/email_fetch.dart'; // Import your Message model

class FetchAttachments {
  static Future<Message> fetchMessageWithAttachments({
    required int uniqueId,
    required String username,
    required String password,
  }) async {
    try {
      MimeMessage mimeMessage = await EmailService.fetchMailByUid(
        uniqueId: uniqueId,
        username: username,
        password: password,
      );

      var infos = mimeMessage.findContentInfo();
      final inlineAttachments = mimeMessage
          .findContentInfo(disposition: ContentDisposition.inline)
          .where((info) =>
              info.fetchId.isNotEmpty &&
              !(info.isText ||
                  info.isImage ||
                  info.mediaType?.sub ==
                      MediaSubtype.messageDispositionNotification));
      infos.addAll(inlineAttachments);

      return Message.fromMimeMessage(
        uniqueId: uniqueId,
        mimeMessage: mimeMessage,
        attachments: infos.toList(),
      );
    } catch (e) {
      logger.e('Error fetching message: $e');
      return Message.fromMimeMessage(
        uniqueId: uniqueId,
        mimeMessage: MimeMessage(), // Provide a default or empty MimeMessage
      );
    }
  }
}
