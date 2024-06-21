import 'package:logger/logger.dart';

import 'package:test_drive/EmailCache/initializeobjectbox.dart';
import '../EmailCache/models/address.dart';

final logger = Logger();

Future<void> saveAddressToDatabase(List<String> addresses) async {
  try {
    for (final address in addresses) {

      try {
        final to_save_address = Address(mailAddress: address);
        bool check = false;

        objectbox.addressBook.getAll().forEach((element) {
          bool flag = element.mailAddress == to_save_address.mailAddress;
          if(flag) check=true;
        });

        // Save Email object to the database
        if(check){
          logger.i('Address $to_save_address already saved.');
        }else {
          objectbox.addressBook.put(to_save_address);
          logger.i('Address $to_save_address saved successfully.');
        }
      } catch (e) {
        logger.e('Failed to save address: $address');
      }
    }
  } catch (e) {
    logger.e('Error during saving address to database: ${addresses.toString()}');
  }
}
