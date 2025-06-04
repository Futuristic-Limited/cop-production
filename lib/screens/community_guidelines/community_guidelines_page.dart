import 'package:flutter/material.dart';

class CommunityGuidelinesPage extends StatelessWidget {
  const CommunityGuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Guidelines'),
        backgroundColor: const Color.fromRGBO(123, 193, 72, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Our Guidelines',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Be respectful and kind to all members.'),
            SizedBox(height: 6),
            Text('• No hate speech, discrimination, or harassment.'),
            SizedBox(height: 6),
            Text('• Stay on topic and contribute meaningfully.'),
            SizedBox(height: 6),
            Text('• Do not spam or promote irrelevant content.'),
            SizedBox(height: 6),
            Text('• Follow local laws and platform policies.'),
            SizedBox(height: 20),
            Text(
              'Violation of these guidelines may result in removal or banning from the community.',
              style: TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
