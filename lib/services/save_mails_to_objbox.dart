import '../EmailCache/initializeobjectbox.dart' ;
import "../EmailCache/models/email.dart" ;

Future<void> saveEmailsToDatabase(List<dynamic> messages) async {

  objectbox.emailBox.removeAll() ;


  for (final message in messages) {
    final email = Email(
      from: message.from?.isNotEmpty == true
          ? message.from!.first.email
          : 'Unknown',
      to: message.to?.isNotEmpty == true ? message.to!.first.email : 'Unknown',
      subject: message.decodeSubject() ?? 'No Subject',
      body: message.decodeTextPlainPart() ?? 'No Text Body',
      receivedDate: message.decodeDate() ?? DateTime.now(),
      uniqueId : "Soon to add",
      
    );
    print("ready to put");
    objectbox.emailBox.put(email);
    print('saving done') ;
  }
}