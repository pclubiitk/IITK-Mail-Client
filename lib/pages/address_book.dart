import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iitk_mail_client/EmailCache/models/address.dart';

import 'package:iitk_mail_client/pages/compose_mail_page.dart';
import 'package:iitk_mail_client/pages/emai_view_page.dart';
import 'package:iitk_mail_client/services/drawer_item.dart';
import 'package:iitk_mail_client/services/email_fetch.dart';
import 'package:iitk_mail_client/theme_notifier.dart';
import '../EmailCache/initializeobjectbox.dart';
import "../EmailCache/models/email.dart";

class AddressBook extends StatefulWidget {
  const AddressBook({
    super.key,
  });

  @override
  State<AddressBook> createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  List<Address> addresses = objectbox.addressBook.getAll();
  bool _isLoading = true;

  bool deleteAddress(int id) {
    bool result = false;
    setState(() {
      result = objectbox.addressBook.remove(id);
      addresses = objectbox.addressBook.getAll();
    });
    return result;
  }

  bool addAddress(Address address) {
    bool check = false;

    objectbox.addressBook.getAll().forEach((element) {
      bool flag = element.mailAddress == address.mailAddress;
      if (flag) check = true;
    });

    if (check) {
      return check;
    } else {
      objectbox.addressBook.put(address);
    }
    setState(() {
      addresses = objectbox.addressBook.getAll();
    });
    return true;
  }

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Row(
          children: [
            Text(
              'Saved Addresses',
              style: theme.textTheme.titleLarge?.copyWith(
                color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: theme.iconTheme.color,
              ),
              onPressed: () {
                themeNotifier.toggleTheme();
              },
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      drawer: const Drawer(child: DrawerItems()),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: addresses.length,
                separatorBuilder: (context, index) =>
                    Divider(color: theme.dividerColor),
                itemBuilder: (context, index) {
                  final address = addresses[index].mailAddress;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      child: Text(
                        address[0].toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: themeNotifier.isDarkMode
                                ? Colors.black
                                : Colors.white),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel_outlined),
                      onPressed: () => showAlertDialog(
                          context, deleteAddress, addresses[index].id),
                    ),
                    title: Text(
                      address,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addAddressDialog(context, addAddress),
        backgroundColor: theme.floatingActionButtonTheme.backgroundColor ??
            theme.primaryColor,
        child: Icon(Icons.add,
            color: themeNotifier.isDarkMode ? Colors.black : Colors.white),
      ),
    );
  }
}

showAlertDialog(BuildContext context, bool Function(int) delete, int id) {
  /// set up the buttons
  Widget cancelButton = GestureDetector(
    child: Text("Cancel"),
    onTap: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = GestureDetector(
    child: Text("Delete"),
    onTap: () {
      if (delete(id)) {
        Navigator.of(context).pop();
      }
    },
  );
  /// set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Delete Address"),
    content: Text("Are you sure you want to delete the address?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

addAddressDialog(BuildContext context, bool Function(Address) add) {
  final theme = Theme.of(context);
  TextEditingController _controller = TextEditingController();
  Widget cancelButton = GestureDetector(
    child: Text("Cancel"),
    onTap: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = GestureDetector(
    child: Text("Add Address"),
    onTap: () {
      Address address = Address(mailAddress: _controller.text);
      if (add(address)) {
        Navigator.of(context).pop();
      }
    },
  );
  /// set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Add Address"),
    content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor,
          hintText: 'Address',
          hintStyle: theme.textTheme.bodyMedium,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        )),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
