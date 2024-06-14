import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_drive/main.dart';

class NavbarItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final Function() onTap;
  const NavbarItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap, TextStyle? textStyle, Color? iconColor
    });

  @override
  State<NavbarItem> createState() => _NavbarItemState();
}

class _NavbarItemState extends State<NavbarItem> {
 
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return  ListTile(
                leading:  Icon(widget.icon, color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
                title: Text(
                  widget.text,
                  style: TextStyle(color:  themeNotifier.isDarkMode ? Colors.white : Colors.black),
                ),
                onTap: widget.onTap,
              );
  }
}