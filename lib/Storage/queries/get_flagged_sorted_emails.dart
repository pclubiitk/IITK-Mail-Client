import "package:iitk_mail_client/Storage/models/email.dart";

import "../initializeobjectbox.dart" ;
import "../../objectbox.g.dart" ;

List<Email> getFlaggedAndSortedEmails() {
  final query = objectbox.emailBox
          .query(Email_.isFlagged.equals(true))
          .order(Email_.uniqueId, flags: Order.descending)
          .build();
  final emails = query.find();
  return emails;
}

