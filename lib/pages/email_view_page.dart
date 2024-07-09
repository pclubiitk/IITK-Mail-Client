// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:iitk_mail_client/Storage/models/email.dart';
import 'package:iitk_mail_client/Storage/models/message.dart';
import 'package:iitk_mail_client/Storage/queries/toggle_flagged_status.dart';
import 'package:iitk_mail_client/pages/forward_screen.dart';
import 'package:iitk_mail_client/pages/reply_screen.dart';
import 'package:iitk_mail_client/services/download_files.dart';
import 'package:iitk_mail_client/services/fetch_attachment.dart';
import 'package:iitk_mail_client/services/open_files.dart';
import 'package:iitk_mail_client/services/imap_service.dart';
import 'package:iitk_mail_client/services/secure_storage_service.dart';
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
  late bool isFlagged;
  final logger = Logger();
  final downloader = DownloadFiles();
  final opener = OpenFiles();
  Message? message;
  List<ContentInfo>? attachments;
  List<MimePart>? mimeParts;
  String? username;
  String? password;

  @override
  void initState() {
    super.initState();
    _setCredentials();
    subject = widget.email.subject ?? 'No Subject';
    sender = widget.email.from ?? 'Unknown Sender';
    body = widget.email.body ?? 'No Content';
    date = widget.email.receivedDate ?? DateTime.now();
    uniqueId = widget.email.uniqueId;
    isFlagged = widget.email.isFlagged;

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
          mimeParts = fetchedMessage.mimeparts;
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

  Future <void> _setCredentials() async{
    username = await SecureStorageService.getUsername();
    password = await SecureStorageService.getPassword();
  }

  Future<void> _handleFlagged() async{
    await ImapService.markMailAsFlaggedOrUnflagged(isFlagged: isFlagged, uniqueId : uniqueId, username: username!, password: password!);
    await toggleFlaggedStatus(widget.email.id);
    setState(() {
      isFlagged = !isFlagged;
    });


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
              /// delete request logic to implemented
            },
          ),
          isFlagged
           ? IconButton(
            icon: Icon(Icons.flag, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () {
              /// add email to flag or starred
              _handleFlagged();
            },
          )
          : IconButton(
            icon: Icon(Icons.flag_outlined, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () {
              /// add email to flag or starred
              _handleFlagged();
            },
          )
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
                for (var i = 0; i < attachments!.length; i++)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (mimeParts != null && i < mimeParts!.length) {
                            final mimePart = mimeParts![i];
                            // Download the file
                            final Uint8List? fileBytes =mimePart.decodeContentBinary();
                            if (fileBytes != null) {
                              final String fileName = attachments![i].fileName ?? 'Unnamed';
                              final String? filePath =await DownloadFiles().downloadFileFromBytes(
                                  fileBytes,
                                  fileName,
                                  keepDuplicate: true,
                                );

                              // Open the file
                              if (filePath != null) {
                                await opener.open(filePath);
                              } else {
                                logger.i('Failed to download file.');
                              }
                            } else {
                              logger.i('Failed to decode attachment content.');
                            }
                          } else {
                            logger.e(
                              'MimePart or attachments list is null or out of bounds',
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            title: Text(
                              attachments![i].fileName ?? 'Unnamed',
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
                              onPressed: () async {
                                // Handle download action for this attachment
                                if (mimeParts != null &&
                                    i < mimeParts!.length) {
                                  final mimePart = mimeParts![i];
                                  final data = mimePart.decodeContentBinary();
                                  final fileName =
                                      attachments![i].fileName ?? 'Unnamed';
                                  final path =
                                      await downloader.downloadFileFromBytes(
                                    data!,
                                    fileName,
                                  );
                                  if (path != null) {
                                    logger.i('File downloaded to: $path');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Downloaded to: $path',
                                        ),
                                      ),
                                    );
                                  } else {
                                    logger.e('Failed to download file');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to download file',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
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
