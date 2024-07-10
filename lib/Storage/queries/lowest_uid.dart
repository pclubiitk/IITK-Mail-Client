import "package:iitk_mail_client/Storage/initializeobjectbox.dart";
import "package:iitk_mail_client/objectbox.g.dart" ;

int getLowestUidFromDatabase() {
  // Build a query to get the email with the lowest uniqueId
  final query = objectbox.emailBox
      .query()
      .order(Email_.uniqueId, flags: 0) // Ascending order
      .build();
  final lowestUidEmail = query.findFirst();
  query.close();
  if (lowestUidEmail != null) {
    return int.parse('${lowestUidEmail.uniqueId}');
  }
  return 0; // If no emails are found, return 0
}
