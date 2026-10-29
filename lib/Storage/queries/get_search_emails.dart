import "package:iitk_mail_client/Storage/models/email.dart";
import "package:logger/logger.dart";
import "../initializeobjectbox.dart";
import "../../objectbox.g.dart";
import "../models/advanced_settings_model.dart";
import '../services/imap_service.dart';
import 'package:enough_mail/enough_mail.dart';

final logger = Logger();

List<Email> getSearchEmails({
  required String searchText,
  required String from,
  required DateTime? dateFrom,
  required DateTime? dateTo,
  required bool unread,
  required bool flagged,
  required bool hasAttachment,
  required String username,
  required String password,
  required EmailSettingsModel emailSettings,
}) {
  logger.i("search emails from date: $dateFrom");

  // First, fetch emails from IMAP starting from the specified date
  if (dateFrom != null) {
    _fetchEmailsFromDate(
      dateFrom: dateFrom,
      emailSettings: emailSettings,
      username: username,
      password: password,
    );
  }

  // Then filter from local database
  return getFilteredEmails(
    searchText: searchText,
    from: from,
    dateFrom: dateFrom,
    dateTo: dateTo,
    unread: unread,
    flagged: flagged,
    hasAttachment: hasAttachment,
  );
}

Future<void> _fetchEmailsFromDate({
  required DateTime dateFrom,
  required EmailSettingsModel emailSettings,
  required String username,
  required String password,
}) async {
  final String serverName = emailSettings.imapServer;
  final int port = int.parse(emailSettings.imapPort);
  final client = ImapClient(isLogEnabled: false);

  try {
    await client.connectToServer(serverName, port, isSecure: port == 993);
    await client.login(username, password);
    await client.selectInbox();

    // Format date for IMAP SEARCH criteria (IMAP format: DD-MMM-YYYY)
    final String imapDate = _formatImapDate(dateFrom);

    // Search for emails from the specified date onwards using IMAP SINCE criteria
    final fetchResult = await client.fetchMessagesByCriteria(
      "SINCE $imapDate (UID FLAGS BODY.PEEK[])",
    );

    logger.i("Fetched ${fetchResult.messages.length} emails from IMAP from $imapDate");

    if (fetchResult.messages.isNotEmpty) {
      await saveEmailsToDatabase(fetchResult.messages);
    }

    await client.logout();
  } on ImapException catch (e) {
    logger.e("IMAP failed during date search: $e");
    rethrow;
  }
}

String _formatImapDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  final year = date.year.toString();
  return '$day-$month-$year';
}
