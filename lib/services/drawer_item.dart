import 'package:flutter/material.dart';
import 'package:test_drive/Components/navbar_item.dart';
import 'package:test_drive/pages/address_book.dart';
import 'package:test_drive/pages/email_list.dart';
import 'package:test_drive/pages/login_page.dart';
import 'package:test_drive/services/secure_storage_service.dart';
import '../pages/settings_page.dart';

/// The widget for side navigation bar, lists down NavBarItem widget for each navigation item
class DrawerItems extends StatefulWidget {
  const DrawerItems({super.key});

  @override
  State<DrawerItems> createState() => _DrawerItemsState();
}

class _DrawerItemsState extends State<DrawerItems> {
  String? username;

  String? password;

  Future<void> getCredentials() async {
    username = await SecureStorageService.getUsername();
    password = await SecureStorageService.getPassword();
  }

  @override
  void initState() {
    getCredentials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.drawerTheme.backgroundColor,
      child: ListView(
        children: [
          NavbarItem(
            icon: Icons.inbox,
            text: 'Inbox',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EmailListPage(
                          username: username!, password: password!)));
            },
            textStyle: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          NavbarItem(
            icon: Icons.outbox,
            text: 'Outbox',
            onTap: () {},
            textStyle: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          NavbarItem(
            icon: Icons.flag,
            text: 'Flagged',
            onTap: () {},
            textStyle: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          NavbarItem(
            icon: Icons.delete,
            text: 'Trash',
            onTap: () {},
            textStyle: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          NavbarItem(
            icon: Icons.save_alt_rounded,
            text: 'Address Book',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddressBook()));
            },
            textStyle: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          Divider(color: theme.dividerColor),
          NavbarItem(
            icon: Icons.settings,
            text: 'Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            textStyle: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          NavbarItem(
            icon: Icons.login_sharp,
            text: 'Log Out',
            onTap: () {
              SecureStorageService.clearCredentials();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            textStyle: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
        ],
      ),
    );
  }
}
