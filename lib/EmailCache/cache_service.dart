import "./initializeobjectbox.dart" ;
import "./models/email.dart" ;
import "./objectbox.dart" ;
import "../objectbox.g.dart" ;


int getHighestUidFromDatabase() {
      // Assuming objectbox.emailBox contains the Email entities
      final query = objectbox.emailBox
          .query()
          .order(Email_.uniqueId, flags: Order.descending)
          .build();
      final highestUidEmail = query.findFirst();
      query.close();
      if (highestUidEmail != null) {
        return int.parse('${highestUidEmail.uniqueId}');
      }
      return 0; // If no emails are found, return 0
    }