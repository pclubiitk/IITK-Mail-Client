import 'package:iitk_mail_client/Storage/initializeobjectbox.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<void> markSeen(int emailId) async {
  /// Retrieve the email by its ID
  final email = objectbox.emailBox.get(emailId);
  

  /// If the email exists, mark it seen in local storage
  if (email != null) {
    logger.i(email.uniqueId);
    email.isRead = true;
    objectbox.emailBox.put(email);
    logger.i('Email with ID ${email.uniqueId} has been marked seen');
  } else {
    logger.e('Email with ID ${email!.uniqueId} not found');
  }
}