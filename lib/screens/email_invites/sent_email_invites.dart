import 'dart:convert';

import 'package:APHRC_COP/models/message_model.dart';
import 'package:APHRC_COP/screens/messages/lottie.dart';
import 'package:APHRC_COP/services/token_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SentInvites extends StatefulWidget {
  const SentInvites({super.key});

  @override
  State<SentInvites> createState() => _SentInvitesState();
}

class _SentInvitesState extends State<SentInvites> {
  List<Invite> _invites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvites();
  }

  Future<void> fetchInvites() async {
    final apiUrl = dotenv.env['API_URL'];
    final token = await SaveAccessTokenService.getAccessToken();
    try {
      final url = Uri.parse('$apiUrl/invites/get_user_invites');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final String errorMessage =
          data['messages']?['error'] ?? 'Unknown error occurred';
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List invitesJson = data['invites'];

        setState(() {
          _invites = invitesJson.map((json) => Invite.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching invites: $e')));
      return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sent Invites',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _invites.isEmpty
                ? LottieEmpty(title: 'No invites found')
                : ListView.builder(
              itemCount: _invites.length,
              itemBuilder: (context, index) {
                final invite = _invites[index];
                return Card(
                  elevation: 0,
                  color: const Color(0xFFE8F5E9),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite #${invite.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Email: ${invite.email}'),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${invite.accepted ? "Accepted" : "Pending"}',
                        ),
                        const SizedBox(height: 4),
                        Text('Date Sent: ${invite.dateModified}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
