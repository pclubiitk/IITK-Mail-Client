import 'package:flutter/material.dart';
import 'package:test_drive/Components/address_book.dart';
import 'package:test_drive/EmailCache/initializeobjectbox.dart';
import 'package:test_drive/services/send_mail.dart';
import 'package:test_drive/services/snackbar_navigate.dart';
import 'package:provider/provider.dart';
import '../models/advanced_settings_model.dart';

class ComposeEmailPage extends StatefulWidget {
  final String username;
  final String password;

  const ComposeEmailPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<ComposeEmailPage> createState() => _ComposeEmailPageState();
}

class _ComposeEmailPageState extends State<ComposeEmailPage> {
  final List<TextEditingController> _toController = [TextEditingController()];
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isLoading = false;
  String? _snackBarMessage;
  Color _snackBarColor = Colors.green;

  Future<void> _sendEmail() async {
    final emailSettings =
        Provider.of<EmailSettingsModel>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    await EmailSender.sendEmail(
      emailSettings: emailSettings,
      username: widget.username,
      password: widget.password,
      to: _toController.map((e) => e.text).toList(),
      subject: _subjectController.text,
      body: _bodyController.text,
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
            onPressed: _isLoading ? null : _sendEmail,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 26.0, horizontal: 18),
        color: theme.scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
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
                  'To  ',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: InputChipField(
                        suggestionList: objectbox.addressBook
                            .getAll()
                            .map(
                              (e) => e.mailAddress,
                            )
                            .toList(),
                        textControllers: _toController)),
              ],
            ),
            Divider(
              thickness: 0.5,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            Row(
              children: [
                Text(
                  'Subject',
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    cursorColor: theme.colorScheme.onSurface.withOpacity(0.6),
                    maxLines: null,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 0.5,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            Expanded(
              child: TextField(
                controller: _bodyController,
                style: TextStyle(color: theme.colorScheme.onSurface),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
