import 'dart:convert';
import 'package:APHRC_COP/models/message_model.dart';
import 'package:APHRC_COP/screens/messages/chat_screen.dart';
import 'package:APHRC_COP/screens/messages/lottie.dart';
import 'package:APHRC_COP/screens/messages/new_conversation.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:APHRC_COP/utils/format_time_utils.dart';
import 'package:APHRC_COP/utils/html_utils.dart';
import 'package:APHRC_COP/utils/uppercase_first_letter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  // init state

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<MessageThread> threads = [];
  bool isLoading = true;
  String? errorMessage;
  String? user;

  @override
  void initState() {
    super.initState();
    fetchInbox();
  }

  Future<void> fetchInbox() async {
    final token = await SharedPrefsService.getAccessToken();
    final userId = await SharedPrefsService.getUserId();
    final apiUrl = dotenv.env['API_URL'];

    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = "Access token not found.";
      });
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/messages/fetch_inbox/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> nestedThreads = data['threads'];
        final List<dynamic> threadList = nestedThreads['threads'];
        final String userIdStr = nestedThreads['sender_id'].toString();

        setState(() {
          threads =
              threads =
              threadList
                  .map((json) => MessageThread.fromJson(json))
                  .toList();
          user = userIdStr;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to fetch inbox (${response.statusCode})";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error fetching inbox: $e";
      });
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body:
      isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.fromARGB(255, 28, 196, 107),
          ),
        ),
      )
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : threads.isEmpty
          ? LottieEmpty(title: 'Start a conversation!')
          : ListView.builder(
        itemCount: threads.length,
        itemBuilder: (context, index) {
          final thread = threads[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                thread.participantAvatar ?? '',
              ),
            ),
            title: Text(capitalizeFirstLetter(thread.participantName)),
            subtitle: Text(
              stripHtmlWithEmojis(thread.latestMessage),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatTime(thread.latestDateSent),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                if (thread.unreadCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        thread.unreadCount.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () async {
              final currentUserId =
              await SharedPrefsService.getUserId();

              int otherUserId;
              if (thread.participantId == currentUserId.toString()) {
                otherUserId = int.parse(thread.senderId);
              } else {
                otherUserId = int.parse(thread.participantId);
              }

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BuddyBossThreadScreen(
                    threadId: int.parse(thread.threadId),
                    userId: otherUserId,
                    userName: thread.participantName,
                    profilePicture: thread.participantAvatar ?? '',
                  ),
                ),
              );
              if (result == 'refresh') {
                // Refresh the inbox if the user sent a new message
                fetchInbox();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.message, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
              const NewMessageScreen(title: 'New Conversation'),
            ),
          );
        },
      ),
    );
  }
}