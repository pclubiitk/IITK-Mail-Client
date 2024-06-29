// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:iitk_mail_client/EmailCache/models/email.dart';
import 'package:iitk_mail_client/EmailCache/models/message.dart';
import 'package:iitk_mail_client/pages/forward_screen.dart';
import 'package:iitk_mail_client/pages/reply_screen.dart';
import 'package:iitk_mail_client/services/email_fetch.dart';
import 'package:iitk_mail_client/services/attachment_chip.dart';
import 'package:iitk_mail_client/services/fetch_attachment.dart';
import 'package:logger/logger.dart';

class EmailViewPage extends StatefulWidget {
  final Email email;
  final String username;
  final String password;

  const EmailViewPage({
    super.key,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  State<EmailViewPage> createState() => _EmailViewPageState();
}

class _EmailViewPageState extends State<EmailViewPage> {
  late final String subject;
  late final String sender;
  late final String body;
  late final DateTime date;
  late final int uniqueId;
  final logger = Logger();
  Message? message;
  List<ContentInfo>? attachments;

  @override
  void initState() {
    super.initState();
    subject = widget.email.subject ?? 'No Subject';
    sender = widget.email.from ?? 'Unknown Sender';
    body = widget.email.body ?? 'No Content';
    date = widget.email.receivedDate ?? DateTime.now();
    uniqueId = widget.email.uniqueId;

    // Fetch attachments if the email has attachments\
    if (widget.email.hasAttachment) {
      FetchAttachments.fetchMessageWithAttachments(
        uniqueId: uniqueId,
        username: widget.username,
        password: widget.password,
      ).then((Message fetchedMessage) {
        setState(() {
          message = fetchedMessage;
          attachments = fetchedMessage.attachments;
        });
        for (var attachment in attachments!) {
          logger.i(
              'Attachment found: ${attachment.fileName ?? 'Unnamed attachment'}');
        }
      }).catchError((error) {
        logger.e('Failed to fetch message: $error');
      });
    }
  }

  // Widget _buildAttachments(List<ContentInfo> attachments) {
  //   return Wrap(
  //     children: [
  //       for (final attachment in attachments)
  //         AttachmentChip(info: attachment, message: message!) as Widget,
  //     ],
  //   );
  // }

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
                      sender[0].toUpperCase(),
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
                          sender,
                          maxLines: null,
                          overflow: TextOverflow.fade,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              Divider(color: Colors.grey),
              //attachment
              if (widget.email.hasAttachment && attachments != null) ...[
                for (var attachment in attachments!)
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(
                            attachment.fileName ?? 'Unnamed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.download),
                            onPressed: () {
                              // Handle download action for this attachment
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                const Divider(color: Colors.grey),
              ],
              const SizedBox(height: 8),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black87,
                  fontSize: 16,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.reply),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReplyEmailPage(
                                email: widget.email,
                                username: widget.username,
                                password: widget.password,
                              ),
                            ),
                          );
                        },
                      ),
                      Text(
                        'Reply',
                        style: TextStyle(
                          color: theme.appBarTheme.iconTheme?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForwardEmailPage(
                                email: widget.email,
                                username: widget.username,
                                password: widget.password,
                              ),
                            ),
                          );
                        },
                      ),
                      Text(
                        'Forward',
                        style: TextStyle(
                          color: theme.appBarTheme.iconTheme?.color,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
