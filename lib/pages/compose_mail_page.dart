import 'package:flutter/material.dart';
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
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isLoading = false;
  String? _snackBarMessage;
  Color _snackBarColor = Colors.green;

  Future<void> _sendEmail() async {
    final emailSettings = Provider.of<EmailSettingsModel>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    await EmailSender.sendEmail(
      emailSettings: emailSettings,
      username: widget.username,
      password: widget.password,
      to: _toController.text,
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(43, 39, 39, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _isLoading ? null : _sendEmail,
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 50,
                  child: Text(
                    'To:',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _toController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade900),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(
                  width: 50,
                  child: Text(
                    'From:',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: Text(
                    "${widget.username}@iitk.ac.in",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(
                  width: 70,
                  child: Text(
                    'Subject:',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _subjectController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade900),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _bodyController,
                style: const TextStyle(color: Colors.white),
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
