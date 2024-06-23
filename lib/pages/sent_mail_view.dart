// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:iitk_mail_client/EmailCache/models/email.dart';

class SentEmailViewPage extends StatefulWidget {
  final Email email;
  final String username;
  final String password;

  const SentEmailViewPage({
    super.key,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  State<SentEmailViewPage> createState() => _SentEmailViewPageState();
}

class _SentEmailViewPageState extends State<SentEmailViewPage> {
  late final String subject;
  late final String sender;
  late final String recipient;
  late final String body;
  late final DateTime date;

  @override
  void initState() {
    super.initState();
    subject = widget.email.subject ?? 'No Subject';
    sender = widget.email.from ?? 'Unknown Sender';
    recipient=widget.email.to??'Unknown Recipient';
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
          icon:
              Icon(Icons.arrow_back, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () {
              // delete request logic to implemented
            },
          ),
          IconButton(
            icon: Icon(Icons.flag, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () {
              // add email to flag or starred
            },
          ),
        ],
      ),
      body: Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(
                        recipient[0].toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.day}-${date.month}-${date.year}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.grey,
                                fontSize: 14),
                          ),
                          Text(
                            recipient,
                            maxLines: null,
                            overflow: TextOverflow.fade,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                      fontSize: 16),
                ),
               
              ],
            ),
          )),
    );
  }
}