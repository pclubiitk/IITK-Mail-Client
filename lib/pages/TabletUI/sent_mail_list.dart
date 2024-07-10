import 'package:flutter/material.dart';
import 'package:iitk_mail_client/pages/compose_mail_page.dart';
import 'package:iitk_mail_client/services/drawer_item.dart';
import 'package:iitk_mail_client/services/drawer_item_tablet.dart';
import 'package:iitk_mail_client/services/email_fetch.dart';
import 'package:iitk_mail_client/models/advanced_settings_model.dart';
import 'package:iitk_mail_client/theme_notifier.dart';
import 'package:iitk_mail_client/EmailCache/initializeobjectbox.dart';
import "package:iitk_mail_client/EmailCache/models/email.dart";
import 'package:provider/provider.dart';
import 'package:iitk_mail_client/services/fetch_sentmail.dart';
import 'package:iitk_mail_client/pages/TabletUI/sent_mail_view.dart';
class SentEmailListPageTablet extends StatefulWidget {
  final String username;
  final String password;

  const SentEmailListPageTablet({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<SentEmailListPageTablet> createState() => _EmailListPageState();
}

class _EmailListPageState extends State<SentEmailListPageTablet> {
  List<Email> emails = [];
  bool _isLoading = true;
  late Email sent_email_showing;

  @override
  void initState() {
    super.initState();
    _fetchEmails();
  }

  Future<void> _fetchEmails() async {
    final emailSettings =
        Provider.of<EmailSettingsModel>(context, listen: false);
    try {
      final fetchedSentEmails =await SentEmailService.fetchSentEmails(
        emailSettings: emailSettings,
        username: widget.username,
        password: widget.password,
      );
      setState(() {
        emails = fetchedSentEmails;
        sent_email_showing = emails[0];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to fetch emails: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Row(
          children: [
            Text(
              'Sent Mails',
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
      drawer: const Drawer(child: DrawerItemsTablet()),
      body: Row(
        children: [
          Container(
            width: screenWidth/3,
            color: theme.scaffoldBackgroundColor,
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: emails.length,
              separatorBuilder: (context, index) =>
                  Divider(color: theme.dividerColor),
              itemBuilder: (context, index) {
                final email = emails[index];
                final subject = email.subject ?? 'No Subject';
                final receiver = email.to ?? 'Unknown Sender';
                final date = email.receivedDate ?? DateTime.now();
                final time =
                    '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      print("Click");
                      this.sent_email_showing = email;
                    });
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      child: Text(
                        receiver[0].toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: themeNotifier.isDarkMode
                                ? Colors.black
                                : Colors.white),
                      ),
                    ),
                    title: Text(
                      receiver,
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
                                  ?.withOpacity(0.4)),
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
                    :SentEmailViewPage(key: Key(sent_email_showing.uniqueId.toString()) ,email: sent_email_showing,username: widget.username,password: widget.password),
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
