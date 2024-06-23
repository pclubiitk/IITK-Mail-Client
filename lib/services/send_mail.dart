import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import '../models/advanced_settings_model.dart';
import 'package:iitk_mail_client/services/save_address_to_objbox.dart';


/// the sendEmail method of the class accepts the email components, connects to the SMTP client of iitk,
/// sends ehlo command to the server,builds a MIME message, wraps the body in plain text & html text,
/// spefifies the from ,to and subject field and then send the message to recipient client
/// we give out corresponding messages depending upon the outcome
/// then the mail is also saved in INBOX.Sent mailbox using IMAP server

class EmailSender {
  static Future<void> sendEmail({
    required String username,
    required String password,
    required List<String> to,
    required String subject,
    required String body,
    required Function(String, Color) onResult,
    required EmailSettingsModel emailSettings,
  }) async {
    final String smtpServerName=emailSettings.smtpServer;
    final int smtpPort=int.parse(emailSettings.smtpPort);
    final String imapServerName=emailSettings.imapServer;
    final int imapPort=int.parse(emailSettings.imapPort);
    final String domainName=emailSettings.domain;
    
    final client = SmtpClient('enough_mail', isLogEnabled: true);
    final imapClient = ImapClient(isLogEnabled: true);
    try {
      await client.connectToServer(smtpServerName, smtpPort, isSecure: smtpPort == 465);
      await client.ehlo();

      await client.authenticate(username, password, AuthMechanism.plain);

      final builder = MessageBuilder.prepareMultipartAlternativeMessage(
        plainText: body,
        htmlText: "<p>$body</p>",
      )

        ..from = [MailAddress(username, '$username@$domainName')]
     
        ..to = to.map((e) => MailAddress(e, e)).toList()

        ..subject = subject;

      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client.sendMessage(mimeMessage);
    await imapClient.connectToServer(imapServerName, imapPort, isSecure: imapPort==993);
    await imapClient.login(username, password);

 
    final mailboxPath = 'INBOX.Sent';
    final mailbox = await imapClient.selectMailboxByPath(mailboxPath);

    await imapClient.appendMessage(mimeMessage, targetMailbox: mailbox);

      if (sendResponse.isOkStatus) {
        saveAddressToDatabase(to);
        onResult('Email sent successfully', Colors.green);
      } else {
        onResult(
            'Failed to send email: Failed to establish connection with server',
            Colors.red);
      }
    } catch (e) {
      onResult('Failed to send email: $e', Colors.red);
    } finally {
      await imapClient.logout();
      await client.quit();
    }
  }
}
