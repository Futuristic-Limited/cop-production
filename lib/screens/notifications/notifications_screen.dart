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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid notification ID')),
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
          const SnackBar(content: Text('Failed to mark as read')),
        );
      }
    }
  }

  Widget buildNotificationTile(dynamic notification, bool isUnread) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFE9F8E4) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? const Color(0xFF79C148) : Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: isUnread ? const Color(0xFF79C148) : Colors.grey,
          child: const Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(
          notification['title'] ?? 'No title',
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            notification['message'] ?? '',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        trailing: isUnread
            ? ElevatedButton(
          onPressed: () => markAsRead(notification['id']),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF79C148),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('Mark Read', style: TextStyle(fontSize: 12)),
        )
            : const SizedBox(),
      ),
    );
  }

  Widget buildSection(String title, List<dynamic> items, bool isUnread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isUnread ? const Color(0xFF79C148) : Colors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUnread ? const Color(0xFF79C148) : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ...items.map((n) => buildNotificationTile(n, isUnread)),
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              buildSection('Unread', unread, true),
              const SizedBox(height: 20),
              buildSection('Read', read, false),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}