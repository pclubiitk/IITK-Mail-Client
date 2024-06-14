import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:test_drive/pages/compose_mail_page.dart';
import 'package:test_drive/pages/emai_view_page.dart';

import 'package:test_drive/services/drawer_item.dart';
import 'package:test_drive/services/email_fetch.dart';

class EmailListPage extends StatefulWidget {
  final String username;
  final String password;
  final String server;
  final bool isSecure;

  const EmailListPage({
    super.key,
    required this.username,
    required this.password,
    required this.server,
    required this.isSecure,
  });

  @override
  State<EmailListPage> createState() => _EmailListPageState();
}

class _EmailListPageState extends State<EmailListPage> {
  List<MimeMessage> emails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  Future<void> _fetchEmails() async {
    try {
      final fetchedEmails = await EmailService.fetchEmails(
        username: widget.username,
        password: widget.password,
        server: widget.server,
        isSecure: widget.isSecure,
      );
      setState(() {
        emails = fetchedEmails;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to fetch emails: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(43, 39, 39, 1),
        title: Row(
          children: [
            const Text('Inbox', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            CircleAvatar(
              child: Text(widget.username[0].toUpperCase()),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const Drawer(child: DrawerItems()),
      body: Container(
        color: Colors.black,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: emails.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.grey),
                itemBuilder: (context, index) {
                  final email = emails[index];
                  final subject = email.decodeSubject() ?? 'No Subject';
                  final sender = email.from?.first.email ?? 'Unknown Sender';
                  final date = email.decodeDate() ?? DateTime.now();
                  final time = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailViewPage(email: email),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(sender[0].toUpperCase()),
                      ),
                      title: Text(sender, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(subject, style: const TextStyle(color: Colors.white)),
                          Text(
                            email.decodeTextPlainPart() ?? 'No Content',
                            style: const TextStyle(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                          ),
                          Text(
                            time,
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComposeEmailPage(
                username: widget.username,
                password: widget.password,
                server: widget.server,
                isSecure: widget.isSecure,
              ),
            ),
          );
        },
        backgroundColor: Colors.blueGrey.shade600,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
