import 'package:flutter/material.dart';
import 'package:iitk_mail_client/EmailCache/cache_service.dart';
import 'package:iitk_mail_client/EmailCache/mail_dir.dart';
import 'package:iitk_mail_client/pages/compose_mail_page.dart';
import 'package:iitk_mail_client/pages/TabletUI/emai_view_page.dart';
import 'package:iitk_mail_client/services/drawer_item.dart';
import 'package:iitk_mail_client/services/drawer_item_desktop.dart';
import 'package:iitk_mail_client/services/drawer_item_tablet.dart';
import 'package:iitk_mail_client/services/email_fetch.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:iitk_mail_client/models/advanced_settings_model.dart';
import 'package:iitk_mail_client/theme_notifier.dart';
import 'package:iitk_mail_client/EmailCache/initializeobjectbox.dart';
import "package:iitk_mail_client/EmailCache/models/email.dart";
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

final logger = Logger();

class EmailListPageDesktop extends StatefulWidget {
  final String username;
  final String password;
  const EmailListPageDesktop({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<EmailListPageDesktop> createState() => _EmailListPageState();
}

class _EmailListPageState extends State<EmailListPageDesktop> {
  List<Email> emails = [];
  late Email email_showing;
  bool _isLoading = true;
  ///ScrollController controller = ScrollController();
  late Maildir maildir;
  int oldHighestUid = 0;

  @override
  void initState() {
    super.initState();
    ///controller.addListener(_loadmore);
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
        email_showing = emails[0];
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
    final screenWidth = MediaQuery.of(context).size.width;

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
      body: Row(
        children: [
          Container(width: screenWidth/8.8,
              child: Drawer(child: DrawerItemsDesktop(),width: screenWidth/10,)),
          RefreshIndicator(
            onRefresh: _loadmore,
            child: Container(
              width: screenWidth/3.7,
              color: theme.scaffoldBackgroundColor,
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: emails.length,
                separatorBuilder: (context, index) =>
                    Divider(color: theme.dividerColor),
                itemBuilder: (context, index) {
                  final email = emails[index];
                  final subject = email.subject;
                  final sender = email.senderName;
                  final date = email.receivedDate;
                  final body = email.body;
                  final time =
                      '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                  DateTime now = DateTime.now();
                  Duration difference = now.difference(date);
                  final String day;
                  String normalizeSpaces(String text) {
                    return text.replaceAll(RegExp(r'\s+'), ' ');
                  }

                  if (difference.inDays == 0) {
                    day = time;
                  } else {
                    day = '${date.day}/${date.month}/${date.year}';
                  }
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        this.email_showing = email;
                      });
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.primaryColor,
                        child: Text(
                          sender[0].toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: themeNotifier.isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 15),
                        ),
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sender.length > 23
                                    ? '${sender.substring(0, 23)}...'
                                    : sender,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: themeNotifier.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                day,
                                style: TextStyle(
                                  color: themeNotifier.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                              if (email.hasAttachment)
                                Icon(
                                  Icons.attach_file,
                                  size: 15,
                                  color: theme.iconTheme.color,
                                )
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(subject.trim(),
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeNotifier.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            normalizeSpaces(body),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const VerticalDivider(
            width: 20,
            thickness: 1,
            indent: 20,
            endIndent: 0,
            color: Colors.grey,
          ),
          Expanded(
              child: Container(
                width: screenWidth*(2/3),
                child: _isLoading
                  ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                )
                :EmailViewPage(key: Key(email_showing.uniqueId.toString()) ,email: email_showing,username: widget.username,password: widget.password),
              )
          )
        ],
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
