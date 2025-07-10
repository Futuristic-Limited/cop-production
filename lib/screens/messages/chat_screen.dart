
import 'dart:convert';
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
// Models
import 'package:APHRC_COP/models/buddyboss_thread.dart';

// Services
import 'package:APHRC_COP/services/token_preference.dart';

// Utils
import 'package:APHRC_COP/utils/format_time_utils.dart';
import 'package:APHRC_COP/utils/uppercase_first_letter.dart';

// Widgets
import 'package:APHRC_COP/screens/messages/chart_input_field.dart';

import 'attachment_document.dart';
import 'attachment_photo.dart';
import 'attachment_video.dart';

final apiUrl = dotenv.env['API_URL'];
final buddyBossApiUrl = dotenv.env['WP_API_URL'];

class BuddyBossThreadScreen extends StatefulWidget {
  const BuddyBossThreadScreen({
    super.key,
    required this.threadId,
    required this.userId,
    required this.profilePicture,
    required this.userName,
  });

  final int threadId;
  final int userId;
  final String profilePicture;
  final String userName;

  @override
  State<BuddyBossThreadScreen> createState() => _BuddyBossThreadScreenState();
}

class _BuddyBossThreadScreenState extends State<BuddyBossThreadScreen> {
  final _scrollController = ScrollController();
  bool isLoading = false;
  String? errorMessage;
  BuddyBossThread? thread;
  String? _accessToken;
  final HtmlUnescape _htmlUnescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    if (widget.threadId == 0) return;
    _init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _fetchThread(widget.threadId);
  }

  Future<void> _getAccessToken() async {
    final token = await SaveAccessTokenService.getBuddyToken();

    if (token != null) {
      setState(() {
        _accessToken = token;
      });
    }
  }

  Future<void> _fetchThread(int threadId) async {
    print('Fetching thread with ID: $threadId');
    await _getAccessToken();
    try {
      if (threadId == 0) return;

      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse(
          '${buddyBossApiUrl}wp-json/buddyboss/v1/messages/$threadId?per_page=100',
        ),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          thread = BuddyBossThread.fromJson(json.decode(response.body));
          isLoading = false;
        });

        _scrollToBottom();
      } else {
        setState(() {
          errorMessage = 'Failed to load thread: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String messageText, String attachmentIds) async {
    try {
      await _getAccessToken();
      final currentUserId = await SharedPrefsService.getUserId();
      final Map<String, dynamic> payload = {
        'message':
        (messageText.isEmpty && attachmentIds.isNotEmpty)
            ? ''
            : messageText,
      };

      if (attachmentIds.isNotEmpty) {
        payload['bp_media_ids'] = [attachmentIds];
      }

      if (widget.threadId > 0) {
        payload['thread_id'] = widget.threadId;
        payload['recipients'] = [widget.userId];
        payload['sender_id'] = currentUserId;
      } else {
        payload['recipients'] = [widget.userId];
        payload['subject'] = 'New message';
      }

      final response = await http.post(
        Uri.parse('${buddyBossApiUrl}wp-json/buddyboss/v1/messages'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newThreadId = responseData['id'];
        if (widget.threadId > 0) {
          await _fetchThread(widget.threadId);
        } else {
          await _fetchThread(newThreadId);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _stripHtml(String html) {
    return _htmlUnescape.convert(html.replaceAll(RegExp(r'<[^>]*>'), ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, 'refresh'),
        ),
      ),
      body: SafeArea(
        child:
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : Column(
          children: [
            // Message List
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  reverse: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 12,
                      right: 12,
                      top: 10,
                    ),
                    itemCount: thread?.messages.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = thread!.messages[index];
                      final isSentByUser =
                          message.senderId == widget.userId;

                      return Align(
                        alignment:
                        isSentByUser
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 3,
                          ),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth:
                            MediaQuery.of(context).size.width *
                                0.75,
                          ),
                          decoration: BoxDecoration(
                            color:
                            isSentByUser
                                ? const Color.fromARGB(
                              255,
                              175,
                              174,
                              174,
                            )
                                : const Color(0xFF7A7E7A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              // Attachments (Photos)
                              if (message.bpMediaIds != null &&
                                  message.bpMediaIds!.isNotEmpty)
                                MessageImageGallery(
                                  mediaList: message.bpMediaIds!,
                                  accessToken: _accessToken!,
                                ),

                              // Attachments (Videos)
                              if (message.bpVideos != null &&
                                  message.bpVideos!.isNotEmpty)
                                MessageVideoGallery(
                                  videoList: message.bpVideos!,
                                  accessToken: _accessToken!,
                                ),
                              // Attachments (Documents)
                              if (message.bpDocuments != null &&
                                  message.bpDocuments!.isNotEmpty)
                                MessageDocumentGallery(
                                  documents: message.bpDocuments!,
                                  accessToken: _accessToken!,
                                ),

                              // Message Text
                              if (message.message.rendered.isNotEmpty)
                                Text(
                                  _stripHtml(message.message.rendered),
                                  style: TextStyle(
                                    color:
                                    isSentByUser
                                        ? Colors.white
                                        : Colors.white,
                                    fontSize: 15,
                                  ),
                                ),

                              // Time
                              const SizedBox(height: 5.0),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  formatTimeHumanReadable(
                                    message.dateSent,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                    isSentByUser
                                        ? Colors.white70
                                        : Colors.white70,
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
              ),
            ),

            // Message Input
            ChatInputField(onSendMessage: _sendMessage),
          ],
        ),
      ),
    );
  }
}