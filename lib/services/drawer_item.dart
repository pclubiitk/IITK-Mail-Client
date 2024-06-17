import 'package:flutter/material.dart';
import 'package:test_drive/Components/navbar_item.dart';
import 'package:test_drive/pages/login_page.dart';

import 'package:test_drive/services/secure_storage_service.dart';

/// The widget for side navigation bar, lists down NavBarItem widget for each navigation item
class DrawerItems extends StatelessWidget {
  const DrawerItems({super.key});

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
            onTap: () {},
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
            onTap: () {
          
            },
            textStyle: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
            iconColor: theme.iconTheme.color,
          ),
          NavbarItem(
            icon: Icons.login_sharp,
            text: 'Log Out',
            onTap: () {
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
