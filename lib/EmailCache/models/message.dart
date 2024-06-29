import 'package:enough_mail/enough_mail.dart';
import 'package:intl/intl.dart';

class Message {
  final int uniqueId;
  final MimeMessage mimeMessage;
  final List<ContentInfo> attachments;
  // bool isEmbedded = false;
  // MessageSource? source;

  Message({
    required this.uniqueId,
    required this.mimeMessage,
    required this.attachments,
  });

  factory Message.fromMimeMessage({
    required int uniqueId,
    required MimeMessage mimeMessage,
    List<ContentInfo>? attachments,
  }) {
    return Message(
      uniqueId: uniqueId,
      mimeMessage: mimeMessage,
      attachments: attachments ?? [], // Ensure attachments are initialized
    );
  }
}
