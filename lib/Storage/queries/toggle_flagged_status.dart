import 'package:iitk_mail_client/Storage/initializeobjectbox.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<void> toggleFlaggedStatus(int emailId) async {
  /// Retrieve the email by its ID
  final email = objectbox.emailBox.get(emailId);
  

  /// If the email exists, toggle the isFlagged value and save it back
  if (email != null) {
    logger.i(email.uniqueId);
    email.isFlagged = !email.isFlagged;
    objectbox.emailBox.put(email);
    logger.i('Email with ID ${email.uniqueId} has its isFlagged status changed to ${email.isFlagged}');
  } else {
    logger.e('Email with ID ${email!.uniqueId} not found');
  }
}