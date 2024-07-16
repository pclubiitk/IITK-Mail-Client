import 'package:objectbox/objectbox.dart';

@Entity()
class Email {
  int id;
  String from;
  String to;
  String subject;
  String body;
  DateTime receivedDate;
  int uniqueId;
  int sequenceNumber;
  bool hasAttachment;
  String senderName;
  bool isRead;
  bool isFlagged;
  bool isTrashed;

  Email({
    this.id = 0,
    required this.from,
    required this.to,
    required this.subject,
    required this.body,
    required this.receivedDate,
    required this.uniqueId,
    required this.sequenceNumber,
    required this.hasAttachment,
    required this.senderName,
    required this.isRead,
    required this.isFlagged,
    required this.isTrashed,
  });
}
