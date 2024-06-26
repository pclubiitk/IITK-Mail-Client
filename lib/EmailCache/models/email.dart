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
  bool hasAttachment;

  Email({
    this.id = 0,
    required this.from,
    required this.to,
    required this.subject,
    required this.body,
    required this.receivedDate,
    required this.uniqueId,
    required this.hasAttachment,
  });
}
