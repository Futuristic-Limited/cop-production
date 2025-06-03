
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('You have a new follower'),
          ),
          ListTile(
            leading: Icon(Icons.comment),
            title: Text('Someone commented on your post'),
          ),
        ],
      ),
    );
  }
}
