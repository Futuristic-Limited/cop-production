import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: const Color.fromRGBO(123, 193, 72, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.event, color: Colors.green),
              title: Text('June 20 - Community Clean-Up'),
              subtitle: Text('Join us as we clean up the local park.'),
            ),
            ListTile(
              leading: Icon(Icons.event, color: Colors.green),
              title: Text('July 5 - Health & Wellness Seminar'),
              subtitle: Text('Learn about mental and physical well-being.'),
            ),
            // Add more event items as needed
          ],
        ),
      ),
    );
  }
}
