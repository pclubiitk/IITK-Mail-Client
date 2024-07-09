import 'package:iitk_mail_client/Storage/initializeobjectbox.dart';
import 'package:logger/logger.dart';

final logger = Logger();

Future<void> toggleTrashedStatus(int emailId) async {
  /// Retrieve the email by its ID
  final email = objectbox.emailBox.get(emailId);
  

  /// If the email exists, toggle the isFlagged value and save it back
  if (email != null) {
    logger.i(email.uniqueId);
    email.isTrashed = !email.isTrashed;
    objectbox.emailBox.put(email);
    logger.i('Email with ID ${email.uniqueId} has its isFlagged status changed to ${email.isTrashed}');
  } else {
    logger.e('Email with ID ${email!.uniqueId} not found');
  }
}