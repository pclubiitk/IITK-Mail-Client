import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:iitk_mail_client/EmailCache/maildir.dart';
import '../objectbox.g.dart'; // created by 'flutter pub run build_runner build'
import 'models/email.dart';
import 'models/address.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store store;

  // Add the Box for Email
  late final Box<Email> emailBox;
  late final Box<Address> addressBook;
  late final Maildir maildir;

  ObjectBox._create(this.store,this.maildir) {
    emailBox = Box<Email>(store);
    addressBook = Box<Address>(store);
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store =
        await openStore(directory: p.join(docsDir.path, "obx-example"));
    final maildir = await Maildir.create(p.join(docsDir.path, "maildir")); // Initialize Maildir
    return ObjectBox._create(store,maildir);
  }
}
