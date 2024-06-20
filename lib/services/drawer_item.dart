import 'package:flutter/material.dart';
import 'package:test_drive/Components/navbar_item.dart';
import 'package:test_drive/pages/login_page.dart';
import 'package:test_drive/pages/sent_mail_list.dart';
import 'package:test_drive/pages/email_list.dart';
import 'package:test_drive/services/secure_storage_service.dart';
import '../pages/settings_page.dart';

/// The widget for side navigation bar, lists down NavBarItem widget for each navigation item
class DrawerItems extends StatelessWidget {
   final String username;
  final String password;
  const DrawerItems({
    super.key,
    required this.username,
    required this.password,
    });

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
            onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                 
                  builder: (context) => EmailListPage(username: username,password:password,),
                ),
              );},
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
           NavbarItem(
            icon: Icons.send,
            text: 'Sent',
            onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                 
                  builder: (context) => SentEmailListPage(username: username,password:password,),
                ),
              );},
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          NavbarItem(
            icon: Icons.outbox,
            text: 'Outbox',
            onTap: () {},
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          NavbarItem(
            icon: Icons.flag,
            text: 'Flagged',
            onTap: () {},
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          NavbarItem(
            icon: Icons.delete,
            text: 'Trash',
            onTap: () {},
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          Divider(color: theme.dividerColor),
          NavbarItem(
            icon: Icons.settings,
            text: 'Settings',
            onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                 
                  builder: (context) => const SettingsPage(),
                ),
              );},
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
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
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
        ],
      ),
    );
  }
}