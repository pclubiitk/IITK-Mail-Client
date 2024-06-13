import 'package:flutter/material.dart';
import 'package:test_drive/Components/navbar_item.dart';
import 'package:test_drive/pages/login_page.dart';
import 'package:test_drive/services/secure_storage_service.dart';

/// The widget for side navigation bar, lists down NavBarItem widget for each navigation item

class DrawerItems extends StatelessWidget {
  const DrawerItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(56, 57, 69, 0.941),
      child: ListView(
        children: [
          NavbarItem(icon: Icons.inbox, text: 'Inbox', onTap: () {}),
          NavbarItem(icon: Icons.outbox, text: 'Outbox', onTap: () {}),
          NavbarItem(icon: Icons.flag, text: 'Flagged', onTap: () {}),
          NavbarItem(icon: Icons.delete, text: 'Trash', onTap: () {}),
          const Divider(),
          NavbarItem(icon: Icons.settings, text: 'Settings', onTap: () {}),
          NavbarItem(icon: Icons.login_sharp, text: 'Log Out', onTap: () {
            SecureStorageService.clearCredentials();  //To clear the saved credentials when logged out
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
