import 'package:flutter/material.dart';
import 'package:iitk_mail_client/EmailCache/cache_service.dart';
import 'package:iitk_mail_client/EmailCache/mail_dir.dart';
import 'package:iitk_mail_client/pages/compose_mail_page.dart';
import 'package:iitk_mail_client/pages/emai_view_page.dart';
import 'package:iitk_mail_client/services/drawer_item.dart';
import 'package:iitk_mail_client/services/email_fetch.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../models/advanced_settings_model.dart';
import 'package:iitk_mail_client/theme_notifier.dart';
import '../EmailCache/initializeobjectbox.dart';
import "../EmailCache/models/email.dart";
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

final logger = Logger();

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
  //ScrollController controller = ScrollController();
  late Maildir maildir;
  int oldHighestUid = 0;

  @override
  void initState() {
    super.initState();
    //controller.addListener(_loadmore);
    _initializeMaildir();
    _fetchEmails();
  }

  Future<void> _initializeMaildir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    maildir = await Maildir.create(p.join(docsDir.path, "maildir"));
  }

  Future<void> _fetchEmails() async {
    logger.i("fetch emails got hit");
    final emailSettings =
        Provider.of<EmailSettingsModel>(context, listen: false);
    try {
      await EmailService.fetchEmails(
        emailSettings: emailSettings,
        username: widget.username,
        password: widget.password,
      );
      setState(() {
        emails = objectbox.emailBox.getAll();
        emails = emails.reversed.toList();
        _isLoading = false;
      });
      logger.i("Writing mails to disk ...");
      try {
        _writeNewEmailsToMaildir();
        setState(() {
          oldHighestUid = getHighestUidFromDatabase();
        });
        logger.i("Writing emails to disk successfull!");
      } catch (e) {
        logger.i("Writing mails to dish failed with error:\n$e");
      }
    } catch (e) {
      debugPrint("Failed to fetch emails: $e");
    }
  }

  Future<void> _loadmore() async {
    logger.i("loadmore got hit");

    // if (controller.position.pixels >=
    //    (controller.position.maxScrollExtent - 10)) {
    final emailSettings =
        Provider.of<EmailSettingsModel>(context, listen: false);
    try {
      await EmailService.fetchNewEmails(
          emailSettings: emailSettings,
          username: widget.username,
          password: widget.password);
      setState(() {
        emails = objectbox.emailBox.getAll();
        emails = emails.reversed.toList();
        logger.i("Emails after fetching: ${emails.length}");
      });
      try {
        logger.i("Writing mails to disk ...");
        _writeNewEmailsToMaildir();
        setState(() {
          oldHighestUid = getHighestUidFromDatabase();
        });
        logger.i("Writing emails to disk successfull!");
      } catch (e) {
        logger.i("Writing mails to dish failed with error:\n$e");
      }
    } catch (e) {
      debugPrint("Failed to fetch emails: $e");
    }
    // }
  }

  Future<void> _writeNewEmailsToMaildir() async {
    final newEmails =
        emails.where((email) => email.uniqueId > oldHighestUid).toList();
    for (final email in newEmails) {
      final filename = '${email.uniqueId}';
      await maildir.writeEmail(filename, email);
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
        onRefresh: _loadmore,
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
                  // controller: controller,
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
                              email.body ?? 'No Content',
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
                            if (email.hasAttachment)
                              Icon(
                                Icons.attach_file,
                                color: theme.iconTheme.color,
                                size: 20,
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
