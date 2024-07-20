import 'dart:ffi';

import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:flutter/material.dart';
import 'package:iitk_mail_client/Storage/models/email.dart';
import 'package:iitk_mail_client/Storage/queries/get_sorted_emails.dart';
import 'package:iitk_mail_client/pages/compose_mail_page.dart';
import 'package:iitk_mail_client/pages/email_view_page.dart';
import 'package:iitk_mail_client/route_provider.dart';
import 'package:iitk_mail_client/services/drawer_item.dart';
import 'package:iitk_mail_client/services/imap_service.dart';
import 'package:logger/logger.dart';
import '../models/advanced_settings_model.dart';
import 'package:iitk_mail_client/theme_notifier.dart';
import 'package:provider/provider.dart';

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
  bool _isLoadingPastMails = false;
  int oldHighestUid = 0;
  late ScrollController _scrollController;

  _EmailListPageState() {
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100) {
          _fetchPastMails();
        }
      });
  }

  @override
  void initState() {
    super.initState();
    _initiatorWrapper();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initiatorWrapper() async {
    await _fetchEmails();
    await _fetchNewMail();
  }

  Future<void> _fetchEmails() async {
    logger.i("fetch emails got hit");
    setState(() {
      _isLoading = true;
      logger.i("loading set to true");
    });

    try {
      await _fetchInitialEmails();
    } catch (e) {
      logger.e("Error fetching initial emails: $e");
    } finally {
      setState(() {
        emails = getEmailsOrderedByUniqueId();
        _isLoading = false;
        logger.i("loading set to false");
      });
    }
  }

  Future<void> _fetchInitialEmails() async {
    logger.i("fetch initial mails got hit");
    final emailSettings =
        Provider.of<EmailSettingsModel>(context, listen: false);
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    logger.i(routeProvider.initialRoute);

    if (routeProvider.initialRoute == '/login') {
      try {
        await ImapService.fetchEmails(
          emailSettings: emailSettings,
          username: widget.username,
          password: widget.password,
        );
        routeProvider.initialRoute = '/emailList';
      } catch (e) {
        logger.e("Failed to fetch new emails: $e");
      }
    }
  }

  Future<void> _fetchNewMail() async {
    logger.i("trying to fetch new mails...");
    final emailSettings =
        Provider.of<EmailSettingsModel>(context, listen: false);
    try {
      await ImapService.fetchNewEmails(
          emailSettings: emailSettings,
          username: widget.username,
          password: widget.password);
      setState(() {
        emails = getEmailsOrderedByUniqueId();
        logger.i("Emails after fetching: ${emails.length}");
      });
    } catch (e) {
      debugPrint("Failed to fetch emails: $e");
    }
  }

  Future<void> _fetchPastMails() async {
    logger.i("trying to lazily load past mails");
    if (_isLoadingPastMails) {
      return;
    }
    setState(() {
      _isLoadingPastMails = true;
    });
    try {
      final emailSettings =
          Provider.of<EmailSettingsModel>(context, listen: false);
      await ImapService.fetchOlderEmails(
        emailSettings: emailSettings,
        username: widget.username,
        password: widget.password,
      );
      setState(() {
        emails = getEmailsOrderedByUniqueId();
        logger.i("Emails after fetching: ${emails.length}");
      });
    } catch (e) {
      logger.e("Failed to fetch past mails: $e");
    } finally {
      setState(() {
        _isLoadingPastMails = false;
      });
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
        onRefresh: _fetchNewMail,
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
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: emails.length + (_isLoadingPastMails ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      Divider(color: theme.dividerColor),
                  itemBuilder: (context, index) {
                    if (index == emails.length) {
                      return const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 30),
                          Text('Loading...'),
                        ],
                      );
                    }
                    final email = emails[index];
                    final subject = email.subject;
                    final sender = email.senderName;
                    final date = email.receivedDate;
                    final body =HtmlToPlainTextConverter.convert(email.body);
                    final isSeen = email.isRead;
                    final time =
                        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                    DateTime now = DateTime.now();

                    final String day;
                    String normalizeSpaces(String text) {
                      return text.replaceAll(RegExp(r'\s+'), ' ');
                    }

                    bool isSameDay(DateTime d1, DateTime d2) {
                      if (d1.year == d2.year &&
                          d1.month == d2.month &&
                          d1.day == d2.day) return true;
                      return false;
                    }

                    if (isSameDay(now, date)) {
                      day = time;
                    } else {
                      day = '${date.day}/${date.month}/${date.year}';
                    }
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
                        ).then((_) => _initiatorWrapper());
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
                                  style: isSeen?TextStyle(
                                    fontSize: 10,
                                    color: themeNotifier.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ): TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    color: themeNotifier.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  day,
                                  style: isSeen?TextStyle(   
                                    color: themeNotifier.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 11,
                                  ):TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: themeNotifier.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(subject.trim(),
                                  maxLines: 1,
                                  style: isSeen?TextStyle(
                                    fontSize: 12,
                                    color: themeNotifier.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ):TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: themeNotifier.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                normalizeSpaces(body),
                                style: isSeen?TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                ):TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                              ),
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
