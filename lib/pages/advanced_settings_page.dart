import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/advanced_settings_model.dart';
import '../services/secure_storage_service.dart';
import '../theme_notifier.dart';

/// This page handles the Advanced Settings. It retrieve the va
/// As we change the values in fields, it dynamically updates the values in the model as well.
/// When we click save, it updates the model and populates the provider with it
/// and also stores the configuration in secure storage.

class CustomInputDecoration {
  static InputDecoration getInputDecoration(
      String labelText, IconData icon, ThemeData theme) {
    return InputDecoration(
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor,
      labelText: labelText,
      labelStyle: theme.textTheme.bodyMedium,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: theme.iconTheme.color),
    );
  }
}

class AdvancedSettingsPage extends StatefulWidget {
  @override
  _AdvancedSettingsPageState createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  late EmailSettingsModel tempSettings;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    tempSettings = await SecureStorageService.loadSettings();
    setState(() {
      isLoading = false;
    });
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
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Advanced Settings',
            style: theme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          iconTheme: theme.appBarTheme.iconTheme,
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Advanced Settings',
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.primaryColor,
            ),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: tempSettings.domain,
                style: theme.textTheme.bodyMedium,
                decoration: CustomInputDecoration.getInputDecoration(
                    'Domain', Icons.domain, theme),
                onChanged: (value) {
                  setState(() {
                    tempSettings.updateDomain(value);
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: tempSettings.imapServer,
                style: theme.textTheme.bodyMedium,
                decoration: CustomInputDecoration.getInputDecoration(
                    'IMAP Server', Icons.cloud, theme),
                onChanged: (value) {
                  setState(() {
                    tempSettings.updateImapServer(value);
                    tempSettings.updateAuthServerType('IMAP');
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: tempSettings.imapPort,
                style: theme.textTheme.bodyMedium,
                decoration: CustomInputDecoration.getInputDecoration(
                    'IMAP Port', Icons.portrait, theme),
                onChanged: (value) {
                  setState(() {
                    tempSettings.updateImapPort(value);
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: tempSettings.smtpServer,
                style: theme.textTheme.bodyMedium,
                decoration: CustomInputDecoration.getInputDecoration(
                    'SMTP Server', Icons.cloud, theme),
                onChanged: (value) {
                  setState(() {
                    tempSettings.updateSmtpServer(value);
                    tempSettings.updateAuthServerType('SMTP');
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: tempSettings.smtpPort,
                style: theme.textTheme.bodyMedium,
                decoration: CustomInputDecoration.getInputDecoration(
                    'SMTP Port', Icons.portrait, theme),
                onChanged: (value) {
                  setState(() {
                    tempSettings.updateSmtpPort(value);
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: theme.inputDecorationTheme.fillColor,
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
                    child: Text(
                      'IMAP (${tempSettings.imapServer})',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'SMTP',
                    child: Text(
                      'SMTP (${tempSettings.smtpServer})',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Authenticate using',
                  labelStyle: theme.textTheme.bodyMedium,
                  filled: true,
                  fillColor: theme.inputDecorationTheme.fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: theme
                      .elevatedButtonTheme.style?.backgroundColor
                      ?.resolve({}),
                ),
                child: Text(
                  'Save',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.elevatedButtonTheme.style?.foregroundColor
                        ?.resolve({}),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
