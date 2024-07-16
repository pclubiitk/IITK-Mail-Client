import "package:iitk_mail_client/Storage/models/email.dart";

import "../initializeobjectbox.dart" ;
import "../../objectbox.g.dart" ;

List<Email> getEmailsOrderedByUniqueId() {
  final query = objectbox.emailBox
          .query(Email_.isTrashed.equals(false))
          .order(Email_.uniqueId, flags: Order.descending)
          .build();
  final emails = query.find();
  return emails;
}

