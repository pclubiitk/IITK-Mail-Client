import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:iitk_mail_client/services/save_mails_to_objbox.dart';

final logger = Logger(); // Initializing the logger

class Maildir {
  final Directory maildir; // Main maildir directory
  final Directory cur; 
  final Directory newDir; 
  final Directory tmp; // Temporary directory for emails

  // Private constructor to initialize the directories
  Maildir._create(this.maildir, this.cur, this.newDir, this.tmp);

  // Static method to create and initialize the Maildir structure
  static Future<Maildir> create(String path) async {
    final maildir = Directory(path); // Main maildir path
    final cur = Directory(p.join(path, 'cur')); // Path for cur directory
    final newDir = Directory(p.join(path, 'new')); // Path for new directory
    final tmp = Directory(p.join(path, 'tmp')); // Path for temp directory

    // Create directories if they don't exist
    if (!maildir.existsSync()) maildir.createSync(recursive: true);
    if (!cur.existsSync()) cur.createSync(recursive: true);
    if (!newDir.existsSync()) newDir.createSync(recursive: true);
    if (!tmp.existsSync()) tmp.createSync(recursive: true);

    return Maildir._create(maildir, cur, newDir, tmp);
  }

  // Method to move an email from 'new' to 'cur' directory
  Future<void> moveEmailToCur(String filename) async {
    final File newFile = File(p.join(newDir.path, filename)); // Get the email file from 'new' directory
    logger.i(newFile); // Log the file info
    if (newFile.existsSync()) {
      await newFile.rename(p.join(cur.path, filename)); // Move the file to 'cur' directory
    }
  }

  // Method to write an email to the 'new' directory via 'tmp' directory
  Future<void> writeEmail(String filename, MimeMessage message) async {
    // Create a temp file path in the 'tmp' directory
    final String tempFilename = p.join(tmp.path, filename);
    final File tmpFile = File(tempFilename);
    await tmpFile.writeAsString(message.toString()); // Write the email message to the temp file
    await tmpFile.rename(p.join(newDir.path, filename)); // Move the temp file to 'new' directory
    logger.i("move complete to new"); 
  }
}
