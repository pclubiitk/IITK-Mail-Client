import 'package:flutter/material.dart';
import 'package:iitk_mail_client/pages/compose_mail_page.dart';
import 'package:iitk_mail_client/pages/email_view_page.dart';
import 'package:iitk_mail_client/services/drawer_item.dart';
import 'package:iitk_mail_client/services/imap_service.dart';
import '../models/advanced_settings_model.dart';
import 'package:iitk_mail_client/theme_notifier.dart';
import '../Storage/initializeobjectbox.dart';
import "../Storage/models/email.dart";
import 'package:provider/provider.dart';
import 'package:iitk_mail_client/services/fetch_sentmail.dart';
import 'sent_mail_view.dart';
class SentEmailListPage extends StatefulWidget {
  final String username;
  final String password;
  const SentEmailListPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<SentEmailListPage> createState() => _EmailListPageState();
}

class _EmailListPageState extends State<SentEmailListPage> {
  List<Email> emails = [];
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Failed to fetch emails: $e");
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
      drawer: const Drawer(child: DrawerItems()),
      body: Container(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SentEmailViewPage(
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
     
    );
  }
}
