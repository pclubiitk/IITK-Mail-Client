import 'package:flutter/material.dart';

import 'package:iitk_mail_client/Components/navbar_item.dart';
import 'package:iitk_mail_client/pages/DesktopUI/address_book.dart';
import 'package:iitk_mail_client/pages/DesktopUI/email_list.dart';
import 'package:iitk_mail_client/pages/DesktopUI/login_page.dart';
import 'package:iitk_mail_client/pages/DesktopUI/sent_mail_list.dart';
import 'package:iitk_mail_client/pages/DesktopUI/email_list.dart';
import 'package:iitk_mail_client/services/secure_storage_service.dart';
import 'package:iitk_mail_client/pages/DesktopUI/settings_page.dart';

/// The widget for side navigation bar, lists down NavBarItem widget for each navigation item


class DrawerItemsDesktop extends StatefulWidget {
  const DrawerItemsDesktop({super.key});

  @override
  State<DrawerItemsDesktop> createState() => _DrawerItemsState();
}

class _DrawerItemsState extends State<DrawerItemsDesktop> {
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
    final screenWidth = MediaQuery.of(context).size.width;

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
                      builder: (context) => EmailListPageDesktop(
                          username: username!, password: password!)));
            },
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
           NavbarItem(
            icon: Icons.send,
            text: 'Sent',
            onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                 
                  builder: (context) => SentEmailListPageDesktop(username: username!,password:password!,),
                ),
              );},
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
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
