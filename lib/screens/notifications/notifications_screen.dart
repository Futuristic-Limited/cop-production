import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/shared_prefs_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> unread = [];
  List<dynamic> read = [];
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
        final List<dynamic> notifications = data['notifications'];

        setState(() {
          unread = notifications.where((n) => n['is_new'] == 1).toList();
          read = notifications.where((n) => n['is_new'] == 0).toList();
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

  Future<void> markAsRead(dynamic id) async {
    final intId = int.tryParse(id.toString()) ?? 0;
    if (intId == 0) {
      // handle invalid id
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid notification id')),
        );
      }
      return;
    }

    try {
      final token = await SharedPrefsService.getAccessToken();
      final apiUrl = dotenv.env['BPI_URL'] ?? 'http://10.0.2.2:8000';
      final url = Uri.parse('$apiUrl/notifications/mark-read/$intId');

      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        await fetchNotifications();
      } else {
        throw Exception('Failed to mark as read');
      }
    } catch (e) {
      debugPrint('Error marking as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to mark notification as read')),
        );
      }
    }
  }


  Widget buildNotificationTile(dynamic notification, bool isUnread) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(
          Icons.notifications,
          color: isUnread ? const Color(0xFF79C148) : Colors.grey,
        ),
        title: Text(
          notification['title'] ?? 'No title',
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(notification['message'] ?? ''),
        trailing: isUnread
            ? TextButton(
          onPressed: () => markAsRead(notification['id']),
          child: const Text('Mark as read'),
        )
            : null,
      ),
    );
  }

  Widget buildNotificationList() {
    if (unread.isEmpty && read.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No notifications found.'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: [
        if (unread.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Unread',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF79C148),
              ),
            ),
          ),
        ...unread.map((n) => buildNotificationTile(n, true)),
        if (read.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Read',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ...read.map((n) => buildNotificationTile(n, false)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF79C148),
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
          : RefreshIndicator(
        onRefresh: fetchNotifications,
        child: buildNotificationList(),
      ),
    );
  }
}
