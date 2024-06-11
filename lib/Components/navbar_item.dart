import 'package:flutter/material.dart';

class NavbarItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final Function() onTap;
  const NavbarItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap
    });

  @override
  State<NavbarItem> createState() => _NavbarItemState();
}

class _NavbarItemState extends State<NavbarItem> {
  @override
  Widget build(BuildContext context) {
    return  ListTile(
                leading:  Icon(widget.icon, color: Colors.white),
                title: Text(
                  widget.text,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: widget.onTap,
              );
  }
}