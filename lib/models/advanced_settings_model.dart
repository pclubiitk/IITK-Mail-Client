import 'package:flutter/material.dart';

///Model to handle advanced Settings
class EmailSettingsModel extends ChangeNotifier {
  String _domain = 'iitk.ac.in';
  String _imapServer = 'qasid.iitk.ac.in';
  String _imapPort = '993';
  String _smtpServer = 'mmtp.iitk.ac.in';
  String _smtpPort = '465';
  String _authServerType = 'IMAP';

  String get domain => _domain;
  String get imapServer => _imapServer;
  String get imapPort => _imapPort;
  String get smtpServer => _smtpServer;
  String get smtpPort => _smtpPort;
  String get authServerType => _authServerType;

  void updateDomain(String domain) {
    _domain = domain;
    notifyListeners();
  }

  void updateImapServer(String imapServer) {
    _imapServer = imapServer;
    notifyListeners();
  }

  void updateImapPort(String imapPort) {
    _imapPort = imapPort;
    notifyListeners();
  }

  void updateSmtpServer(String smtpServer) {
    _smtpServer = smtpServer;
    notifyListeners();
  }

  void updateSmtpPort(String smtpPort) {
    _smtpPort = smtpPort;
    notifyListeners();
  }

  void updateAuthServerType(String authServerType) {
    _authServerType = authServerType;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'domain': _domain,
        'imapServer': _imapServer,
        'imapPort': _imapPort,
        'smtpServer': _smtpServer,
        'smtpPort': _smtpPort,
        'authServerType': _authServerType,
      };

  void fromJson(Map<String, dynamic> json) {
    _domain = json['domain'];
    _imapServer = json['imapServer'];
    _imapPort = json['imapPort'];
    _smtpServer = json['smtpServer'];
    _smtpPort = json['smtpPort'];
    _authServerType = json['authServerType'];
    notifyListeners();
  }
}
