import 'package:flutter/material.dart';
import 'package:iitk_mail_client/Storage/models/email.dart';
import 'package:iitk_mail_client/Storage/queries/get_trashed_sorted_emails.dart';
import 'package:iitk_mail_client/pages/compose_mail_page.dart';
import 'package:iitk_mail_client/pages/email_view_page.dart';
import 'package:iitk_mail_client/services/drawer_item.dart';
import 'package:iitk_mail_client/theme_notifier.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

final logger = Logger();

class TrashedMailsPage extends StatefulWidget {
  final String username;
  final String password;
  const TrashedMailsPage({
    super.key,
    required this.username,
    required this.password,
    });

  @override
  State<TrashedMailsPage> createState() => _TrashedMailsPageState();
}

class _TrashedMailsPageState extends State<TrashedMailsPage> {
  List<Email> emails = [];


  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }


  Future<void> _fetchEmails() async {
    logger.i("fetch emails got hit");
    setState(() {
      emails = getTrashedAndSortedEmails();
    });
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
              'Trash',
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
                    color: themeNotifier.isDarkMode ? Colors.black : Colors.white),
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
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: 
               ListView.separated(
                padding: const EdgeInsets.all(8.0),
                itemCount: emails.length 
                //+ (_isLoadingPastMails ? 1 : 0)
                ,
                separatorBuilder: (context, index) => Divider(color: theme.dividerColor),
                itemBuilder: (context, index) {
                  if (index == emails.length) {
                    return const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Loading Past Mails'),
                        ],
                      ),
                    );
                  }
                  final email = emails[index];
                  if(email.isTrashed == true){
                    return null;
                  }
                  final subject = email.subject;
                  final sender = email.senderName;
                  final date = email.receivedDate;
                  final body = email.body;
                  final time = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
                        radius: 18,
                        backgroundColor: theme.primaryColor,
                        child: Text(
                          sender[0].toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: themeNotifier.isDarkMode ? Colors.black : Colors.white,
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
                                sender.length > 23 ? '${sender.substring(0, 23)}...' : sender,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                day,
                                style: TextStyle(
                                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(subject.trim(),
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            normalizeSpaces(body),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
        backgroundColor: theme.floatingActionButtonTheme.backgroundColor ?? theme.primaryColor,
        child: Icon(Icons.edit,
            color: themeNotifier.isDarkMode ? Colors.black : Colors.white),
      ),
    );
  }
}
