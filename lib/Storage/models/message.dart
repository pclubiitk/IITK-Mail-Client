import 'package:enough_mail/enough_mail.dart';

class Message {
  final int uniqueId;
  final MimeMessage mimeMessage;
  final List<ContentInfo> attachments;
  final List<MimePart> mimeparts;

  Message({
    required this.uniqueId,
    required this.mimeMessage,
    required this.attachments,
    required this.mimeparts,
  });

  factory Message.fromMimeMessage(
      {required int uniqueId,
      required MimeMessage mimeMessage,
      List<ContentInfo>? attachments,
      List<MimePart>? mimeParts}) {
    return Message(
      uniqueId: uniqueId,
      mimeMessage: mimeMessage,
      attachments: attachments ?? [], // Ensure attachments are initialized
      mimeparts: mimeParts!,
    );
  }
}
