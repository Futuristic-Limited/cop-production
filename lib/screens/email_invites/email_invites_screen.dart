import 'package:APHRC_COP/screens/email_invites/send_email_invite_form.dart';
import 'package:APHRC_COP/screens/email_invites/sent_email_invites.dart';
import 'package:flutter/material.dart';

class SendEmailInvitesScreen extends StatefulWidget {
  const SendEmailInvitesScreen({super.key});

  @override
  State<SendEmailInvitesScreen> createState() => _SendEmailInvitesScreenState();
}

class _SendEmailInvitesScreenState extends State<SendEmailInvitesScreen> {
  bool isSendTabActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Email Invites'),
        elevation: 0, // Optional: remove shadow if needed
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300, // Divider color
            height: 1.0,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Tab buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSendTabActive = true;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isSendTabActive ? Colors.green : Colors.grey[300],
                    foregroundColor:
                        isSendTabActive ? Colors.white : Colors.black,
                  ),
                  child: const Text('Send Invites'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSendTabActive = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        !isSendTabActive ? Colors.green : Colors.grey[300],
                    foregroundColor:
                        !isSendTabActive ? Colors.white : Colors.black,
                  ),
                  child: const Text('Sent Invites'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Content of the selected tab
            Expanded(
              child:
                  isSendTabActive
                      ? const SendEmailInviteForm()
                      : const SentInvites(),
            ),
          ],
        ),
      ),
    );
  }
}
