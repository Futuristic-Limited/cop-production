
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: true,
            onChanged: null,
          ),
          ListTile(
            title: Text('Change Password'),
            leading: Icon(Icons.lock),
          )
        ],
      ),
    );
  }
}
