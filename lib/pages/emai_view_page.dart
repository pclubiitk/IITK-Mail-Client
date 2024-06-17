import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';

class EmailViewPage extends StatefulWidget {
  final MimeMessage email;
  const EmailViewPage({super.key, required this.email});

  @override
  State<EmailViewPage> createState() => _EmailViewPageState();
}

class _EmailViewPageState extends State<EmailViewPage> {
  late final String subject;
  late final String sender;
  late final String body;
  late final DateTime date;

  /// initialise the values of the required fields in initstate 

  @override
  void initState() {
    super.initState();
    subject = widget.email.decodeSubject() ?? 'No Subject';
    sender = widget.email.from?.first.email ?? 'Unknown Sender';
    body = widget.email.decodeTextPlainPart() ?? 'No Content';
    date = widget.email.decodeDate() ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(43, 39, 39, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.reply, color: Colors.white),
            onPressed: () {
              //reply logic yet to be implemented
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              // delete request logic to implemented
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.white),
            onPressed: () {
              // add email to flag or starred 
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  child: Text(sender[0].toUpperCase()),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day}-${date.month}-${date.year}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      sender,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  body,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
