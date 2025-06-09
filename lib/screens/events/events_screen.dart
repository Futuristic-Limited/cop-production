import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  final List<Map<String, String>> events = const [
    {
      'title': 'June 20 - Community Clean-Up',
      'description': 'Join us as we clean up the local park.',
    },
    {
      'title': 'July 5 - Health & Wellness Seminar',
      'description': 'Learn about mental and physical well-being.',
    },
    {
      'title': 'July 25 - Local Food Fair',
      'description': 'Explore delicious foods from local vendors.',
    },
    // Add more events here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: const Color.fromRGBO(123, 193, 72, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: events.length,
                separatorBuilder: (_, __) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    leading: const Icon(Icons.event, color: Colors.green),
                    title: Text(event['title']!),
                    subtitle: Text(event['description']!),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
