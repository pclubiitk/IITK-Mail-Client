import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_drive/pages/compose_mail_page.dart';
import 'package:test_drive/pages/emai_view_page.dart';
import 'package:test_drive/services/drawer_item.dart';
import 'package:test_drive/services/email_fetch.dart';
import 'package:test_drive/theme_notifier.dart';
import '../EmailCache/initializeobjectbox.dart';
import "../EmailCache/models/email.dart";

class EmailListPage extends StatefulWidget {
  final String username;
  final String password;
  const EmailListPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<EmailListPage> createState() => _EmailListPageState();
}

class _EmailListPageState extends State<EmailListPage> {
  List<Email> emails = [];
  bool _isLoading = true;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_loadmore);
    _fetchEmails();
  }

  Future<void> _fetchEmails() async {
    try {
      await EmailService.fetchEmails(
        username: widget.username,
        password: widget.password,
      );

      setState(() {
        emails = objectbox.emailBox.getAll();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to fetch emails: $e");
    }
  }

  Future<void> _loadmore() async {
    if (controller.position.pixels >=
        (controller.position.maxScrollExtent - 10)) {
      try {
        await EmailService.fetchNewEmails(
            username: widget.username, password: widget.password);
        setState(() {
          emails = objectbox.emailBox.getAll();
        });
      } catch (e) {
        debugPrint("Failed to fetch emails: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Row(
          children: [
            Text(
              'Inbox',
              style: theme.textTheme.titleLarge?.copyWith(
                color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: Text(
                widget.username[0].toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                    color:
                        themeNotifier.isDarkMode ? Colors.black : Colors.white),
              ),
            ),
            IconButton(
              icon: Icon(
                themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: theme.iconTheme.color,
              ),
              onPressed: () {
                themeNotifier.toggleTheme();
              },
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      drawer: const Drawer(child: DrawerItems()),
      body: RefreshIndicator(
        onRefresh: _fetchEmails,
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  controller: controller,
                  itemCount: emails.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: theme.dividerColor),
                  itemBuilder: (context, index) {
                    final email = emails[index];
                    final subject = email.subject ?? 'No Subject';
                    final sender = email.from ?? 'Unknown Sender';
                    final date = email.receivedDate ?? DateTime.now();
                    final time =
                        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmailViewPage(
                              email: email,
                              username: widget.username,
                              password: widget.password,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColor,
                          child: Text(
                            sender[0].toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                                color: themeNotifier.isDarkMode
                                    ? Colors.black
                                    : Colors.white),
                          ),
                        ),
                        title: Text(
                          sender,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color),
                            ),
                            Text(
                              email.subject ?? 'No Content',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withOpacity(0.7)),
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withOpacity(0.6)),
                            ),
                            Text(
                              time,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComposeEmailPage(
                  username: widget.username, password: widget.password),
            ),
          );
        },
        backgroundColor: theme.floatingActionButtonTheme.backgroundColor ??
            theme.primaryColor,
        child: Icon(Icons.edit,
            color: themeNotifier.isDarkMode ? Colors.black : Colors.white),
      ),
    );
  }
}
