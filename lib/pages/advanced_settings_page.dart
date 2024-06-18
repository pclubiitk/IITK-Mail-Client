import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/advanced_settings_model.dart';
import '../services/secure_storage_service.dart';

class CustomInputDecoration {
  static InputDecoration getInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[900],
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: Colors.white),
    );
  }
}

class AdvancedSettingsPage extends StatefulWidget {
  @override
  _AdvancedSettingsPageState createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  late EmailSettingsModel tempSettings;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<EmailSettingsModel>(context, listen: false);
    tempSettings = EmailSettingsModel()
      ..updateDomain(settings.domain)
      ..updateImapServer(settings.imapServer)
      ..updateImapPort(settings.imapPort)
      ..updateSmtpServer(settings.smtpServer)
      ..updateSmtpPort(settings.smtpPort)
      ..updateAuthServerType(settings.authServerType);
  }

  void saveSettings() {
    final settings = Provider.of<EmailSettingsModel>(context, listen: false);
    settings.updateDomain(tempSettings.domain);
    settings.updateImapServer(tempSettings.imapServer);
    settings.updateImapPort(tempSettings.imapPort);
    settings.updateSmtpServer(tempSettings.smtpServer);
    settings.updateSmtpPort(tempSettings.smtpPort);
    settings.updateAuthServerType(tempSettings.authServerType);
    SecureStorageService.saveSettings(settings);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Advanced Settings',
          style: TextStyle(
              color: Colors.white), // Setting app bar title color to white
        ),
        backgroundColor:
            Colors.black, // Setting app bar background color to black
        iconTheme: IconThemeData(
            color: Colors.white), // Setting back arrow color to white
      ),
      backgroundColor: Colors.black, // Setting page background color to black
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: tempSettings.domain,
              style:
                  TextStyle(color: Colors.white), // Setting text color to white
              decoration: CustomInputDecoration.getInputDecoration(
                  'Domain', Icons.domain),
              onChanged: (value) {
                setState(() {
                  tempSettings.updateDomain(value);
                });
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: tempSettings.imapServer,
              style:
                  TextStyle(color: Colors.white), // Setting text color to white
              decoration: CustomInputDecoration.getInputDecoration(
                  'IMAP Server', Icons.cloud),
              onChanged: (value) {
                setState(() {
                  tempSettings.updateImapServer(value);
                  tempSettings.updateAuthServerType('IMAP'); // Update auth type
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: tempSettings.imapPort,
              style: const TextStyle(
                  color: Colors.white), // Setting text color to white
              decoration: CustomInputDecoration.getInputDecoration(
                  'IMAP Port', Icons.portrait),
              onChanged: (value) {
                setState(() {
                  tempSettings.updateImapPort(value);
                });
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: tempSettings.smtpServer,
              style:
                  TextStyle(color: Colors.white), // Setting text color to white
              decoration: CustomInputDecoration.getInputDecoration(
                  'SMTP Server', Icons.cloud),
              onChanged: (value) {
                setState(() {
                  tempSettings.updateSmtpServer(value);
                  tempSettings.updateAuthServerType('SMTP'); // Update auth type
                });
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              initialValue: tempSettings.smtpPort,
              style:
                  TextStyle(color: Colors.white), // Setting text color to white
              decoration: CustomInputDecoration.getInputDecoration(
                  'SMTP Port', Icons.portrait),
              onChanged: (value) {
                setState(() {
                  tempSettings.updateSmtpPort(value);
                });
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[900],
              value: tempSettings.authServerType,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    tempSettings.updateAuthServerType(newValue);
                  });
                }
              },
              items: [
                DropdownMenuItem<String>(
                  value: 'IMAP',
                  child: Text('IMAP (${tempSettings.imapServer})',
                      style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'SMTP',
                  child: Text('SMTP (${tempSettings.smtpServer})',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
              decoration: InputDecoration(
                labelText: 'Authenticate using',
                labelStyle: TextStyle(
                    color: Colors.white), // Setting label text color to white
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
