import 'package:flutter/material.dart';
import 'package:iitk_mail_client/EmailCache/models/attachment.dart';
import 'package:iitk_mail_client/EmailCache/models/email.dart';
import 'package:iitk_mail_client/pages/forward_screen.dart';
import 'package:iitk_mail_client/pages/reply_screen.dart';
import 'package:iitk_mail_client/services/download_files.dart';
import 'package:iitk_mail_client/services/fetch_attachments.dart';
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
  List<Attachment> attachments = [];
  late final DownloadFiles downloader = DownloadFiles();

  @override
  void initState() {
    super.initState();
    subject = widget.email.subject ?? 'No Subject';
    sender = widget.email.from ?? 'Unknown Sender';
    body = widget.email.body ?? 'No Content';
    date = widget.email.receivedDate ?? DateTime.now();
    uniqueId = widget.email.uniqueId;
    /// Fetch attachments if the email has attachments
    if (widget.email.hasAttachment) {
      FetchAttachmentsService.fetchAttachments(
              uniqueId: uniqueId,
              username: widget.username,
              password: widget.password)
          .then((result) {
        setState(() {
          attachments = result;
        });
      }).catchError((error) {
        /// Handle error fetching attachments
        logger.e('Error fetching attachments: $error');
      });
    }
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
          IconButton(
            icon: Icon(Icons.flag, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () {
              /// add email to flag or starred
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
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Colors.grey),
                if (widget.email.hasAttachment) ...[
                  SizedBox(height: 8),
                  Column(
                    children: attachments.isEmpty
                        ? [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                                borderRadius: BorderRadius.circular(8.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text(
                                  'Attachment',
                                  style: TextStyle(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.file_download,
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  onPressed: () async {
                                    for (final attachment in attachments) {
                                      /// Download each attachment
                                      final bytes = await attachment.download();
                                      if (bytes != null) {
                                        final savedPath = await downloader
                                            .downloadFileFromBytes(
                                          bytes,
                                          attachment.fileName,
                                          keepDuplicate: true,
                                        );
                                        if (savedPath != null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Attachment downloaded: $savedPath'),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Failed to download attachment'),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ]
                        : attachments.map((attachment) {
                            return ListTile(
                              title: Text(attachment.fileName),
                              subtitle: Text(attachment.size.toString()),
                              trailing: IconButton(
                                icon: Icon(Icons.file_download),
                                onPressed: () {
                                  /// Handle download action
                                },
                              ),
                              /// Other attachment details and actions
                            );
                          }).toList(),
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.grey),
                  SizedBox(height: 16),
                ],
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black87,
                      fontSize: 16),
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
                                    password: widget.password),
                              ),
                            );
                          },
                        ),
                        Text('Reply',
                            style: TextStyle(
                              color: theme.appBarTheme.iconTheme?.color,
                            )),
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
                                    password: widget.password),
                              ),
                            );
                          },
                        ),
                        Text('Forward',
                            style: TextStyle(
                              color: theme.appBarTheme.iconTheme?.color,
                            )),
                      ],
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
