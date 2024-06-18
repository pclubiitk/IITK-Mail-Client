import 'package:flutter/material.dart';
import 'package:test_drive/Components/address_book.dart';
import 'package:test_drive/EmailCache/initializeobjectbox.dart';
import 'package:test_drive/services/send_mail.dart';
import 'package:test_drive/services/snackbar_navigate.dart';

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
    setState(() {
      _isLoading = true;
    });

    await EmailSender.sendEmail(
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
        padding: const EdgeInsets.all(16.0),
        color: theme.scaffoldBackgroundColor,
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
                        fontSize: 16),
                  ),
                ),
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
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    'From:',
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(),
                    //border: Border.all(color: theme.borderColor),
                  ),
                  child: Text(
                    "${widget.username}@iitk.ac.in",
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    'Subject:',
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 16),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _subjectController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
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
