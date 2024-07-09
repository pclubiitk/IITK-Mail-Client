import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iitk_mail_client/Components/address_book.dart';
import 'package:iitk_mail_client/Storage/initializeobjectbox.dart';
import 'package:iitk_mail_client/services/send_mail.dart';
import 'package:iitk_mail_client/services/snackbar_navigate.dart';
import 'package:logger/logger.dart';
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
  List<String> _attachmentPaths = [];
  List<String> _attachmentFileNames = [];
  bool _isLoading = false;
  String? _snackBarMessage;
  Color _snackBarColor = Colors.green;
  final logger = Logger();

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      List<String> paths = result.paths
          .where((path) => path != null)
          .map((path) => path!)
          .toList();

      setState(() {
        _attachmentPaths.addAll(paths); /// Append new paths
        _attachmentFileNames.addAll(paths.map((path) =>
            File(path).path.split('/').last)); /// Append new file names
      });
    }
  }

  Future<void> _sendEmail() async {
    final emailSettings =
        Provider.of<EmailSettingsModel>(context, listen: false);
    List<String> recipients = _toController
        .map((controller) => controller.text.trim())
        .where((email) => email.isNotEmpty) /// Filter out empty strings
        .toList();

    /// Check if there are valid recipients
    if (recipients.isEmpty) {
      setState(() {
        _snackBarMessage = 'No recipients specified';
        _snackBarColor = Colors.red;
        _isLoading = false;
      });
      _showSnackBarAndNavigate();
      return;
    }

    logger.i('Recipients: $recipients');

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
      attachmentPaths: _attachmentPaths,
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
            icon: Icon(Icons.attach_file,
                color: theme.appBarTheme.iconTheme?.color),
            onPressed: _isLoading ? null : _pickFiles,
          ),
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
                  ),
                  child: Text(
                    "${widget.username}@iitk.ac.in",
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ),
              ],
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
                    textControllers: _toController,
                  ),
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
            if (_attachmentFileNames.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _attachmentFileNames
                    .map((fileName) => ListTile(
                          leading: Icon(Icons.attachment),
                          title: Text(fileName),
                        ))
                    .toList(),
              ),
              Divider(
                thickness: 0.5,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
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
