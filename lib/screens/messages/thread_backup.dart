import 'dart:convert';

import 'package:APHRC_COP/models/message_model.dart';
import 'package:APHRC_COP/screens/messages/chart_input_field.dart';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:APHRC_COP/services/token_preference.dart';
import 'package:APHRC_COP/utils/format_time_utils.dart';
import 'package:APHRC_COP/utils/html_utils.dart';
import 'package:APHRC_COP/utils/uppercase_first_letter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final apiUrl = dotenv.env['API_URL'];
final buddyBossApiUrl = dotenv.env['WP_API_URL'];

class ThreadScreen extends StatefulWidget {
  const ThreadScreen({
    super.key,
    this.threadId,
    required this.userId,
    required this.profilePicture,
    required this.userName,
  });

  final String? threadId;
  final int userId;
  final String profilePicture;
  final String userName;

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  List<Message> dummyMessages = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchMessages();
    getThreads();
  }

  Future<void> getThreads() async {
    String? threadId = widget.threadId;
    final token = await SaveAccessTokenService.getBuddyToken();
    final response = await http.get(
      Uri.parse('${buddyBossApiUrl}wp-json/buddyboss/v1/messages/$threadId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('Thread data: $jsonData');
    }
  }

  Future<void> fetchMessages() async {
    final token = await SaveAccessTokenService.getAccessToken();

    if (widget.threadId == null) {
      setState(() {
        isLoading = false;
        dummyMessages = [];
      });
      return; // No messages yet since thread doesn't exist
    }

    if (token == null) {
      setState(() {
        isLoading = false;
        errorMessage = "Access token not found.";
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$apiUrl/messages/thread/${widget.threadId}/user/${widget.userId}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          dummyMessages =
              (jsonData['thread'] as List)
                  .map((item) => Message.fromJson(item))
                  .toList();
          isLoading = false;
          errorMessage = null;
        });
      } else {
        print(
          'Failed to fetch messages: ${response.statusCode} - ${response.body}',
        );
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

  final ScrollController _scrollController = ScrollController();

  Future<void> sendMessage(String messageText) async {
    final token = await SaveAccessTokenService.getAccessToken();
    final prefs = await SharedPreferences.getInstance();
    final chartUserId = prefs.getInt('chartUserId');
    if (token == null) return;

    // If threadId is null, create a new thread
    String? threadId = widget.threadId;
    if (threadId == null) {
      final response = await http.post(
        Uri.parse('$apiUrl/messages/send'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipient_ids': [widget.userId],
          'sender_id': chartUserId,
          'message': messageText,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        threadId =
            jsonData['thread_id']
                .toString(); // Update with actual response field

        setState(() {
          dummyMessages.add(
            Message(
              id: '',
              threadId: threadId ?? '',
              senderId: widget.userId.toString(),
              subject: '',
              message: messageText,
              dateSent: DateTime.now().toIso8601String(),
              isDeleted: '0',
              attachments: [],
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create thread, please try again later.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        );

        return;
      }
    } else {
      // Send message to existing thread
      final response = await http.post(
        Uri.parse('$apiUrl/messages/reply_thread'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'thread_id': threadId,
          'sender_id': chartUserId,
          'recipient_ids': [widget.userId],
          'message': messageText,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        threadId = jsonData['message_id'].toString();

        setState(() {
          dummyMessages.add(
            Message(
              id: '',
              threadId: threadId ?? '',
              senderId: widget.userId.toString(),
              subject: '',
              message: messageText,
              dateSent: DateTime.now().toIso8601String(),
              isDeleted: '0',
              attachments: [],
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to reply to thread, please try again later.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        );

        print(
          'Failed to create thread: ${response.statusCode} - ${response.body}',
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.profilePicture),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                capitalizeFirstLetter(widget.userName),
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                children: [
                  // Scrollable message list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      itemCount: dummyMessages.length,
                      itemBuilder: (context, index) {
                        final message = dummyMessages[index];
                        final isSentByUser =
                            message.senderId.toString() ==
                            widget.userId.toString();
                        final time = message.dateSent;
                        final text = message.message;

                        return Align(
                          alignment:
                              isSentByUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            padding: const EdgeInsets.all(5),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSentByUser
                                      ? const Color(0xFF7BC148)
                                      : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Attachments
                                if (message.attachments.isNotEmpty)
                                  ...message.attachments.map((attachment) {
                                    final isImage = attachment.mimeType
                                        .startsWith('image/');
                                    final isPdf =
                                        attachment.mimeType ==
                                        'application/pdf';

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 6),
                                        if (isImage)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: attachment.downloadUrl,
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (
                                                    context,
                                                    url,
                                                  ) => const SizedBox(
                                                    height: 10,
                                                    width: 10,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                        Icons.broken_image,
                                                        size: 50,
                                                      ),
                                            ),
                                          ),
                                        if (isPdf)
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.picture_as_pdf,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  attachment.title,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 4),
                                        InkWell(
                                          onTap:
                                              () => launchUrl(
                                                Uri.parse(
                                                  attachment.downloadUrl,
                                                ),
                                              ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.download, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                'Download',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }),

                                const SizedBox(height: 6),

                                // Message
                                if (text.isNotEmpty)
                                  Text(
                                    stripHtml(text),
                                    style: TextStyle(
                                      color:
                                          isSentByUser
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),

                                const SizedBox(height: 6),

                                // Time
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    formatTimeHumanReadable(time),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          isSentByUser
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Chart input field
                  ChatInputField(onSendMessage: sendMessage),
                ],
              ),
    );
  }
}
