import 'package:flutter/material.dart';

class GuidelinesScreen extends StatelessWidget {
  const GuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> guidelines = [
      {
        'title': '1. Be Respectful',
        'icon': Icons.emoji_people,
        'points': [
          'Respect everyone regardless of their background or experience.',
          'Disagreements are okay, but remain courteous.',
        ],
      },
      {
        'title': '2. Stay On Topic',
        'icon': Icons.topic,
        'points': [
          'Post content relevant to the group\'s purpose.',
          'Avoid spamming or advertising unrelated services.',
        ],
      },
      {
        'title': '3. Protect Privacy',
        'icon': Icons.lock,
        'points': [
          'Do not share personal information without consent.',
          'Avoid posting sensitive data like phone numbers or addresses.',
        ],
      },
      {
        'title': '4. Report Issues',
        'icon': Icons.report_problem,
        'points': [
          'If you see inappropriate content, report it to moderators.',
          'Help keep the community safe and welcoming.',
        ],
      },
      {
        'title': '5. Engage Constructively',
        'icon': Icons.handshake,
        'points': [
          'Add value to discussions by being thoughtful and inclusive.',
          'Appreciate differing viewpoints with an open mind.',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Guidelines'),
        backgroundColor: const Color.fromRGBO(123, 193, 72, 1),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guidelines.length,
        itemBuilder: (context, index) {
          final guideline = guidelines[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(guideline['icon'], color: Colors.green, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          guideline['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...List<Widget>.from(
                    guideline['points'].map<Widget>((point) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ", style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
