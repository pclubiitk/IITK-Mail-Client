import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:iitk_mail_client/services/save_mails_to_objbox.dart';

final logger = Logger();

class Maildir {
  final Directory maildir;
  final Directory cur;
  final Directory newDir;
  final Directory tmp;

  Maildir._create(this.maildir, this.cur, this.newDir, this.tmp);

  static Future<Maildir> create(String path) async {
    final maildir = Directory(path);
    final cur = Directory(p.join(path, 'cur'));
    final newDir = Directory(p.join(path, 'new'));
    final tmp = Directory(p.join(path, 'tmp'));

    if (!maildir.existsSync()) maildir.createSync(recursive: true);
    if (!cur.existsSync()) cur.createSync(recursive: true);
    if (!newDir.existsSync()) newDir.createSync(recursive: true);
    if (!tmp.existsSync()) tmp.createSync(recursive: true);

    return Maildir._create(maildir, cur, newDir, tmp);
  }

  Future<void> moveEmailToCur(String filename) async {
    final File newFile = File(p.join(newDir.path, filename));
    logger.i(newFile);
    if (newFile.existsSync()) {
      await newFile.rename(p.join(cur.path, filename));
    }
  }

  Future<void> writeEmail(String filename, MimeMessage message) async {
    // final mess = {
    //   'from': message.from?.isNotEmpty == true ? message.from!.first.email : 'Unknown',
    //   'to': message.to?.isNotEmpty == true ? message.to!.first.email : 'Unknown',
    //   'subject': message.decodeSubject() ?? 'No Subject',
    //   'body':message.decodeTextHtmlPart(),
    //   'receivedDate': message.decodeDate() ?? DateTime.now(),
    //   'uniqueId': "Soon to add", // Add unique ID logic if needed
    // };
    final String tempFilename = p.join(tmp.path, filename);
    final File tmpFile = File(tempFilename);
    await tmpFile.writeAsString(message.toString());
    await tmpFile.rename(p.join(newDir.path, filename));
    logger.i("move complete to new");
  }

}
