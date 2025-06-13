import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/shared_prefs_service.dart';
import 'package:intl/intl.dart';


bool isSelectionMode = false;
Set<int> selectedNotifications = {};

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String dateNotified;
  final bool isNew;
  final String action;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateNotified,
    required this.isNew,
    required this.action, // ← add this
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? 'No title',
      message: json['message']?.toString() ?? '',
      dateNotified: json['date_notified']?.toString() ?? '',
      isNew: json['is_new'].toString() == '1',
      action: json['action']?.toString() ?? '', // ← parse this
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  List<NotificationItem> unread = [];
  List<NotificationItem> read = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      hasError = false;
      isSelectionMode = false;
      selectedNotifications.clear();
    });

    try {
      final token = await SharedPrefsService.getAccessToken();
      final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
      final url = Uri.parse('$apiUrl/notifications');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> notificationsJson = data['notifications'] ?? [];

        final all = notificationsJson.map((n) => NotificationItem.fromJson(n)).toList();

        setState(() {
          unread = all.where((n) => n.isNew).toList();
          read = all.where((n) => !n.isNew).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load notifications')),
        );
      }
    }
  }

  Future<void> deleteSelectedNotifications() async {
    if (selectedNotifications.isEmpty) return;

    try {
      final token = await SharedPrefsService.getAccessToken();
      final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
      final url = Uri.parse('$apiUrl/notifications/delete');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'ids': selectedNotifications.toList()}),
      );

      if (response.statusCode == 200) {
        await fetchNotifications();
      } else {
        throw Exception('Failed to delete');
      }
    } catch (e) {
      debugPrint('Error deleting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete notifications')),
        );
      }
    }
  }

  void handleNotificationTap(NotificationItem notification) async {
    final Map<String, String> actionRoutes = {
      'new_message': '/messages',
      'bb_messages_new': '/messages',
      'friendship_request': '/feed',
      'friendship_accepted': '/feed',
      'group_invite': '/groups',
      'new_membership_request': '/groups',
      'bbp_new_reply_3782': '/events',
      'bbp_new_reply_4017': '/events',
      'bbp_new_reply_4044': '/events',
      'reminder': '/reminders',
    };

    final route = actionRoutes[notification.action];
    if (route != null) {
      Navigator.pushNamed(context, route);
      await markAsRead(notification.id);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No destination linked to this notification.')),
      );
    }
  }


  Future<void> markAsRead(int id) async {
    if (id <= 0) return;

    try {
      final token = await SharedPrefsService.getAccessToken();
      final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
      final url = Uri.parse('$apiUrl/notifications/mark-read/$id');

      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        await fetchNotifications();
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Map<String, List<NotificationItem>> groupByDate(List<NotificationItem> items) {
    final Map<String, List<NotificationItem>> grouped = {};
    for (var item in items) {
      final parsedDate = DateTime.tryParse(item.dateNotified);
      if (parsedDate != null) {
        final dateKey = DateFormat('yyyy-MM-dd').format(parsedDate);
        grouped.putIfAbsent(dateKey, () => []).add(item);
      }
    }
    return grouped;
  }

  Widget buildNotificationTile(NotificationItem notification, bool isUnread) {
    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        padding: const EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        color: Colors.green,
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => markAsRead(notification.id),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () {
              if (isSelectionMode) {
                setState(() {
                  if (selectedNotifications.contains(notification.id)) {
                    selectedNotifications.remove(notification.id);
                  } else {
                    selectedNotifications.add(notification.id);
                  }
                });
              } else {
                handleNotificationTap(notification);
              }
            },
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelectionMode)
                  Checkbox(
                    value: selectedNotifications.contains(notification.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedNotifications.add(notification.id);
                        } else {
                          selectedNotifications.remove(notification.id);
                        }
                      });
                    },
                  ),
                CircleAvatar(
                  backgroundColor: isUnread ? const Color(0xFF79C148) : Colors.grey.shade400,
                  child: const Icon(Icons.notifications_none, color: Colors.white),
                ),
              ],
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                notification.message,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              ),
            ),
            trailing: isUnread && !isSelectionMode
                ? TextButton(
              onPressed: () {
                // 1. Mark as read
                markAsRead(notification.id);

                // 2. Action to route mapping
                final actionRoutes = {
                  'new_message': '/messages',
                  'bb_messages_new': '/messages',
                  'friendship_request': '/feed',
                  'group_invite': '/groups',
                  'forum_reply': '/events',

                };

                final route = actionRoutes[notification.action];

                // 3. Navigate if route is valid and not current screen
                if (route != null && ModalRoute.of(context)?.settings.name != route) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context, rootNavigator: true).pushNamed(route);
                  });
                } else {
                  print(' Unknown or same route for action: ${notification.action}');
                }
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF79C148)),
              child: const Text('Mark as read'),
            )
                : null,

          ),

        ),
      ),
    );
  }

  Widget buildGroupedSection(List<NotificationItem> items, bool isUnread) {
    final grouped = groupByDate(items);
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedKeys.map((dateKey) {
        final date = DateTime.tryParse(dateKey);
        final label = date == null
            ? dateKey
            : DateTime.now().difference(date).inDays == 0
            ? 'Today'
            : DateTime.now().difference(date).inDays == 1
            ? 'Yesterday'
            : DateFormat('MMM d, yyyy').format(date);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...grouped[dateKey]!.map((n) => buildNotificationTile(n, isUnread)).toList(),
          ],
        );
      }).toList(),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: const Color(0xFF79C148),
          actions: [
            if (!isLoading && (unread.isNotEmpty || read.isNotEmpty))
              IconButton(
                icon: Icon(isSelectionMode ? Icons.close : Icons.check_box),
                tooltip: isSelectionMode ? 'Cancel Selection' : 'Select Notifications',
                onPressed: () {
                  setState(() {
                    isSelectionMode = !isSelectionMode;
                    if (!isSelectionMode) selectedNotifications.clear();
                  });
                },
              ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Unread'),
              Tab(text: 'Read'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('Failed to load notifications.'),
          ),
        )
            : Stack(
          children: [
            RefreshIndicator(
              onRefresh: fetchNotifications,
              child: TabBarView(
                children: [
                  unread.isEmpty

                      ? _emptyState(Icons.mark_email_unread_outlined, 'No unread notifications')
                      : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [buildGroupedSection(unread, true)],
                  ),
                  read.isEmpty
                      ? _emptyState(Icons.drafts_outlined, 'No read notifications')
                      : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [buildGroupedSection(read, false)],
                  ),
                ],
              ),
            ),

            if (isSelectionMode && selectedNotifications.isNotEmpty)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text('Are you sure you want to delete the selected notifications?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await deleteSelectedNotifications();
                    }
                  },
                  icon: const Icon(Icons.delete),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  label: const Text('Delete Selected'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
