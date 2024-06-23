import 'dart:io';
import 'package:iitk_mail_client/EmailCache/models/email.dart';
import 'package:path/path.dart' as p;
import 'package:enough_mail/enough_mail.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class Maildir {
  final Directory maildir;
  final Directory cur;
  final Directory newDir;
  final Directory tmp;

  Maildir._create(this.maildir, this.cur, this.newDir, this.tmp);

  static Future<Maildir> create(String path) async {

    // initializing the directorie's paths
    final maildir = Directory(path);
    final cur = Directory(p.join(path, 'cur'));
    final newDir = Directory(p.join(path, 'new'));
    final tmp = Directory(p.join(path, 'tmp'));

    // create the directory if it does not exits already
    if (!maildir.existsSync()) maildir.createSync(recursive: true);
    if (!cur.existsSync()) cur.createSync(recursive: true);
    if (!newDir.existsSync()) newDir.createSync(recursive: true);
    if (!tmp.existsSync()) tmp.createSync(recursive: true);

    return Maildir._create(maildir, cur, newDir, tmp);
  }

  // the function takes mail message, first writes in temp directory to ensure it is completely loaded in the disk and is not corrupted in any way,
  // then when it has loaded to disk in temp directory, we move the file to the new directory
  Future<void> writeEmail(String filename, Email message) async {
    final String tempFilename = p.join(tmp.path, filename);
    final File tmpFile = File(tempFilename);
    await tmpFile.writeAsString(message.toString());
    await tmpFile.rename(p.join(newDir.path, filename));
    logger.i("Email with subject ${message.subject} written to new directory: $filename");
  }

  // function to move the mail to cur directory. I have no implemented its use as of this commit. # For future use and yet to be implemented
  Future<void> moveEmailToCur(String filename) async {
    final File newFile = File(p.join(newDir.path, filename));
    if (newFile.existsSync()) {
      await newFile.rename(p.join(cur.path, filename));
      logger.i("Email moved to cur directory: $filename");
    }
  }
}
