
import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:test_drive/EmailCache/models/email.dart';

class EmailViewPage extends StatefulWidget {
  final Email email;
  const EmailViewPage({super.key, required this.email});

  @override
  State<EmailViewPage> createState() => _EmailViewPageState();
}

class _EmailViewPageState extends State<EmailViewPage> {
  late final String subject;
  late final String sender;
  late final String body;
  late final DateTime date;

  @override
  void initState() {
    super.initState();
    subject = widget.email.subject ?? 'No Subject';
    sender = widget.email.from ?? 'Unknown Sender';
    body = widget.email.body ?? 'No Content';
    date = widget.email.receivedDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.black,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon:  Icon(Icons.reply, color:theme.appBarTheme.iconTheme?.color),
            onPressed: () {
              //reply logic yet to be implemented
            },
          ),
          IconButton(
            icon:  Icon(Icons.delete, color:theme.appBarTheme.iconTheme?.color),
            onPressed: () {
              // delete request logic to implemented
            },
          ),
          IconButton(
            icon:  Icon(Icons.flag, color:theme.appBarTheme.iconTheme?.color),
            onPressed: () {
              // add email to flag or starred
            },
          ),
        ],
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    sender[0].toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day}-${date.month}-${date.year}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.grey, fontSize: 14),
                    ),
                    Text(
                      sender,
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}