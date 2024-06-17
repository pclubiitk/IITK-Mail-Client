import 'package:flutter/material.dart';
import 'package:test_drive/pages/advanced_settings_page.dart'; // Import AdvancedSettingsPage

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Setting text color to white
          ),
        ),
        iconTheme: IconThemeData(
            color: Colors.white), // Setting back arrow color to white
      ),
      backgroundColor: Colors.black, // Setting background color to black
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdvancedSettingsPage(),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8), // Adjusting vertical margin
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.grey[900], // Setting card color to dark grey
              child: ListTile(
                title: Text(
                  'Advanced Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Setting text color to white
                  ),
                ),
                leading: Icon(Icons.settings,
                    color: Colors.white), // Setting icon color to white
                trailing: Icon(Icons.arrow_forward_ios,
                    color: Colors.white), // Setting icon color to white
              ),
            ),
          ),
        ],
      ),
    );
  }
}
