import 'package:flutter/material.dart';

class AccessInstructionsPage extends StatelessWidget {
  const AccessInstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {
        'title': 'Step 1: Navigate to the CoP Website',
        'icon': Icons.public,
        'content': [
          'Open your web browser (e.g., Chrome, Firefox, Safari).',
          'In the address bar, type: https://cop.aphrc.org.',
          'Press "Enter" to visit the site.',
        ],
      },
      {
        'title': 'Step 2: Log In or Register',
        'icon': Icons.login,
        'content': [
          'You will see options to either log in or register.',
          'If you already have an account: Enter your username/email and password, then click "Log In."',
          'If new: Click "Register," fill out the required info and submit the form.',
        ],
      },
      {
        'title': 'Step 3: Review Community Guidelines',
        'icon': Icons.rule,
        'content': [
          'First-time users are taken to the Community Guidelines page.',
          'Read through the rules and expectations for participating.',
          'Click to proceed when ready.',
        ],
      },
      {
        'title': 'Step 4: Explore Communities',
        'icon': Icons.groups,
        'content': [
          'Locate navigation options at the top of the screen.',
          'Click "Homepage" or "Our Communities" to view all available communities.',
          'Find and select the “GFGP” community.',
        ],
      },
      {
        'title': 'Step 5: Join a Group',
        'icon': Icons.group_add,
        'content': [
          'Click the "Join" or "Become a Member" button on the community page.',
          'Once approved (if required), access group features and discussions.',
        ],
      },
      {
        'title': 'Step 6: Navigate the Group Interface',
        'icon': Icons.dashboard_customize,
        'content': [
          'Feed: Real-time activity updates.',
          'Discussions: Main hub for group conversations.',
          'Photos: View/upload images.',
          'Members: See all group participants.',
          'Videos: Watch/share video content.',
          'Albums: Browse organized media collections.',
          'Documents: Access shared files like PDFs and text files.',
        ],
      },
      {
        'title': 'Step 7: Participate in Discussions',
        'icon': Icons.chat_bubble_outline,
        'content': [
          'Click on the Discussions tab to join conversations.',
          '#Self Introductions: Introduce yourself to the group.',
          '#General Questions: Ask questions or join ongoing conversations.',
          'Type your message and submit to engage.',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Access the CoP Platform'),
        backgroundColor: const Color.fromRGBO(123, 193, 72, 1),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(step['icon'], color: Colors.green, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step['title'],
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
                    step['content'].map<Widget>((point) {
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
