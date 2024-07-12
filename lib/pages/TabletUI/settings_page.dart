// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:iitk_mail_client/pages/advanced_settings_page.dart';
// import 'package:iitk_mail_client/theme_notifier.dart'; 

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final themeNotifier = Provider.of<ThemeNotifier>(context);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: theme.appBarTheme.backgroundColor,
//         title: Text(
//           'Settings',
//           style: theme.appBarTheme.titleTextStyle,
//         ),
//         iconTheme: theme.appBarTheme.iconTheme,
//         actions: [
//           IconButton(
//             icon: Icon(
//               themeNotifier.isDarkMode ? Icons.light_mode : Icons.dark_mode,
//               color: theme.primaryColor,
//             ),
//             onPressed: () {
//               themeNotifier.toggleTheme();
//             },
//           ),
//         ],
//       ),
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Column(
//         children: [
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => AdvancedSettingsPage(),
//                 ),
//               );
//             },
//             child: Card(
//               margin: const EdgeInsets.symmetric(
//                   horizontal: 16, vertical: 8), 
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               color: theme.inputDecorationTheme.fillColor,
//               child: ListTile(
//                 title: Text(
//                   'Advanced Settings',
//                 ),
//                 leading: Icon(
//                   Icons.settings,
//                   color: theme.iconTheme.color,
//                 ),
//                 trailing: Icon(
//                   Icons.arrow_forward_ios,
//                   color: theme.iconTheme.color,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
