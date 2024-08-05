import 'package:enough_mail_html/enough_mail_html.dart';
import 'package:flutter/material.dart';
import 'package:iitk_mail_client/Storage/models/email.dart';
import 'package:iitk_mail_client/Storage/queries/get_filtered_emails.dart';
import 'package:iitk_mail_client/pages/email_view_page.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:iitk_mail_client/theme_notifier.dart';
import 'package:intl/intl.dart';

final logger = Logger();

class SearchPage extends StatefulWidget {
  final String username;
  final String password;

  const SearchPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  String _from = '';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _unread = false;
  bool _flagged = false;
  bool _hasAttachment = false;
  List<Email> _filteredEmails = [];

  @override
  void initState() {
    super.initState();
    _filterEmails();
  }

  void _filterEmails() {
    logger.i("filtering emails...");
    setState(() {
      _filteredEmails = getFilteredEmails(
        searchText: _searchController.text,
        from: _from,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        unread: _unread,
        flagged: _flagged,
        hasAttachment: _hasAttachment,
      );
    });
  }

  void _showFromBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, 
    builder: (context) {
      TextEditingController _fromController = TextEditingController(text: _from);
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, 
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _fromController,
                  decoration: InputDecoration(
                    labelText: 'From',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _fromController.clear();
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _from = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _from = _fromController.text;
                      _filterEmails();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  void _showDateBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('From Date'),
                trailing: const Icon(Icons.calendar_today),
                subtitle: _dateFrom != null
                    ? Text(DateFormat('dd/MM/yyyy').format(_dateFrom!))
                    : const Text('Select a date'),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dateFrom ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateFrom = picked;
                    });
                    Navigator.pop(context);
                    _showDateBottomSheet();
                  }
                },
              ),
              ListTile(
                title: const Text('To Date'),
                trailing: const Icon(Icons.calendar_today),
                subtitle: _dateTo != null
                    ? Text(DateFormat('dd/MM/yyyy').format(_dateTo!))
                    : const Text('Select a date'),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dateTo ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateTo = picked;
                    });
                    Navigator.pop(context);
                    _showDateBottomSheet();
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _dateFrom = null;
                        _dateTo = null;
                        _filterEmails();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _filterEmails();
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            fillColor: theme.cardColor,
            filled: true,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _filterEmails();
              },
            ),
          ),
          onChanged: (value) {
            _filterEmails();
          },
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('From'),
                  selected: _from.isNotEmpty,
                  onSelected: (selected) {
                    _showFromBottomSheet();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Date'),
                  selected: _dateFrom != null || _dateTo != null,
                  onSelected: (selected) {
                    _showDateBottomSheet();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Unread'),
                  selected: _unread,
                  onSelected: (selected) {
                    setState(() {
                      _unread = selected;
                    });
                    _filterEmails();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Flagged'),
                  selected: _flagged,
                  onSelected: (selected) {
                    setState(() {
                      _flagged = selected;
                    });
                    _filterEmails();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Has Attachment'),
                  selected: _hasAttachment,
                  onSelected: (selected) {
                    setState(() {
                      _hasAttachment = selected;
                    });
                    _filterEmails();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredEmails.length,
              padding: const EdgeInsets.all(1.0),
              separatorBuilder: (context, index) =>
                      Divider(color: theme.dividerColor),
              itemBuilder: (context, index) {
                final email = _filteredEmails[index];
                final subject = email.subject;
                final sender = email.senderName;
                final date = email.receivedDate;
                final body = HtmlToPlainTextConverter.convert(email.body);
                final isSeen = email.isRead;
                final time =
                    '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                DateTime now = DateTime.now();

                final String day;
                String normalizeSpaces(String text) {
                  return text.replaceAll(RegExp(r'\s+'), ' ');
                }

                bool isSameDay(DateTime d1, DateTime d2) {
                  if (d1.year == d2.year &&
                      d1.month == d2.month &&
                      d1.day == d2.day) return true;
                  return false;
                }

                if (isSameDay(now, date)) {
                  day = time;
                } else {
                  day = '${date.day}/${date.month}/${date.year}';
                }

                return GestureDetector(
                   onTap: () {
                     Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmailViewPage(
                              email: email,
                              username: widget.username,
                              password: widget.password,
                            ),
                          ),
                        ).then((_) => _filterEmails());
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      child: Text(
                        sender[0].toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: themeNotifier.isDarkMode ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sender.length > 23 ? '${sender.substring(0, 23)}...' : sender,
                              style: isSeen
                                  ? TextStyle(fontSize: 10, color: themeNotifier.isDarkMode ? Colors.white : Colors.black)
                                  : TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
                            ),
                            Text(
                              day,
                              style: isSeen
                                  ? TextStyle(color: themeNotifier.isDarkMode ? Colors.white : Colors.black, fontSize: 11)
                                  : TextStyle(fontWeight: FontWeight.w900, color: themeNotifier.isDarkMode ? Colors.white : Colors.black, fontSize: 11),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            subject.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isSeen
                                ? TextStyle(fontSize: 12, color: themeNotifier.isDarkMode ? Colors.white : Colors.black)
                                : TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
