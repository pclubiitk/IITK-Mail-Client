import "../initializeobjectbox.dart" ;
import "../../objectbox.g.dart" ;


int getOldestSequenceNumberFromDatabase() {
    final query = objectbox.emailBox
        .query()
        .order(Email_.sequenceNumber)
        .build();
    final oldestEmail = query.findFirst();
    query.close();
    if(oldestEmail?.sequenceNumber!=null){
      return int.parse('${oldestEmail?.sequenceNumber}');
    }
    return 0;
  }