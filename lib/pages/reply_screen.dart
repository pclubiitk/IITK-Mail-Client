import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:iitk_mail_client/EmailCache/models/email.dart';
import 'package:iitk_mail_client/services/reply_mail.dart';
import 'package:iitk_mail_client/services/snackbar_navigate.dart';

class ReplyEmailPage extends StatefulWidget {
  final Email email;
  final String username;
  final String password;

  const ReplyEmailPage({
    super.key,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  State<ReplyEmailPage> createState() => _ReplyEmailPageState();
}

class _ReplyEmailPageState extends State<ReplyEmailPage> {
  final TextEditingController _replyBodyController = TextEditingController();
  bool _isLoading = false;
  bool _isBodyVisible = false;
  String? _snackBarMessage;
  Color _snackBarColor = Colors.green;
  late final String subject;
  late final String sender;
  late final String body;

  void _showSnackBarAndNavigate() {
    setState(() {
      _isLoading = false;
    });
    if (_snackBarMessage != null) {
      SnackbarHelper.showSnackBarAndNavigate(
        context: context,
        message: _snackBarMessage!,
        color: _snackBarColor,
      );
      setState(() {
        _snackBarMessage = null;
      });
    }
  }

  Future<void> _replyEmail() async {
    setState(() {
      _isLoading = true;
    });

    await EmailReply.replyEmail(
      username: widget.username,
      password: widget.password,
      originalMessage: widget.email,
      replyBody: _replyBodyController.text,
      onResult: (message, color) {
        setState(() {
          _snackBarMessage = message;
          _snackBarColor = color;
        });
        _showSnackBarAndNavigate();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    subject = widget.email.subject ?? 'No Subject';
    sender = widget.email.from ?? 'Unknown Sender';
    body = widget.email.body ?? 'No Content';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.send, color: theme.appBarTheme.iconTheme?.color),
            onPressed: _isLoading ? null : _replyEmail,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 26.0, horizontal: 18),
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'From',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.username}@iitk.ac.in',
                    style: TextStyle(
                        fontSize: 17,
                        color: theme.colorScheme.onSurface.withOpacity(0.8)),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              Row(
                children: [
                  Text(
                    'To     ',
                    maxLines: null,
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sender,
                      style: TextStyle(
                          fontSize: 17,
                          color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 0.5,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subject',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subject,
                      maxLines: null,
                      style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.8)),
                    ),
                  )
                ],
              ),
              Divider(
                thickness: 0.5,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              Container(
                // decoration: BoxDecoration(border: Border.all()),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        maxLines: null,
                        cursorColor:
                            theme.colorScheme.onSurface.withOpacity(0.6),
                        controller: _replyBodyController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isBodyVisible = !_isBodyVisible;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isBodyVisible
                                  ? 'Hide Original Message'
                                  : 'Show Original Message',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Icon(
                              _isBodyVisible
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      if (_isBodyVisible)
                        Text(
                          body,
                          maxLines: null,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}