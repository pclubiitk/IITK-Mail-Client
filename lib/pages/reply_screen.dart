import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:test_drive/services/reply_mail.dart';
import 'package:test_drive/services/snackbar_navigate.dart';

class ReplyEmailPage extends StatefulWidget {
  final MimeMessage email;
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
      username: '${widget.username}@iitk.ac.in',
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

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    subject = widget.email.decodeSubject() ?? 'No Subject';
    sender = widget.email.from?.first.email ?? 'Unknown Sender';
    body = widget.email.decodeTextPlainPart() ?? 'No Content';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.iconTheme?.color),
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
        padding: const EdgeInsets.all(16.0),
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      'To:',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                    ),
                    child: Text(
                      widget.email.from?.first.email ?? 'Unknown Sender',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      'From:',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                    ),
                    child: Text(
                      '${widget.username}@iitk.ac.in',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Subject:',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Re: $subject',
                      maxLines: null,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                // decoration: BoxDecoration(border: Border.all()),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        maxLines: null,
                        cursorColor: theme.colorScheme.onSurface.withOpacity(0.6),
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
                              _isBodyVisible ? 'Hide Original Message' : 'Show Original Message',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Icon(
                              _isBodyVisible ? Icons.expand_less : Icons.expand_more,
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
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
