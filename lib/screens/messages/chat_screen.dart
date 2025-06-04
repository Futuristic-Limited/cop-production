import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gallery_saver/gallery_saver.dart';
// Models
import 'package:APHRC_COP/models/buddyboss_thread.dart';
import 'package:APHRC_COP/models/message_model.dart';

// Services
import 'package:APHRC_COP/services/shared_prefs_service.dart';
import 'package:APHRC_COP/services/token_preference.dart';

// Utils
import 'package:APHRC_COP/utils/format_time_utils.dart';
import 'package:APHRC_COP/utils/html_utils.dart';
import 'package:APHRC_COP/utils/uppercase_first_letter.dart';

// Widgets
import 'package:APHRC_COP/screens/messages/chart_input_field.dart';

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
  bool isLoading = true;
  String? errorMessage;
  BuddyBossThread? thread;
  String? _accessToken;
  final HtmlUnescape _htmlUnescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    _fetchThread();
  }

  Future<void> _fetchThread() async {
    try {
      final token = await SaveAccessTokenService.getBuddyToken();

      print('BuddyBoss Token: $token');

      if (token != null) {
        setState(() {
          _accessToken = token;
        });
      }

      final response = await http.get(
        Uri.parse(
          '${buddyBossApiUrl}wp-json/buddyboss/v1/messages/${widget.threadId}',
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

  Future<void> _sendMessage(String messageText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getInt('chartUserId');

      final response = await http.post(
        Uri.parse('${buddyBossApiUrl}wp-json/buddyboss/v1/messages'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'thread_id': widget.threadId,
          'message': messageText,
          'sender_id': currentUserId,
          'recipients': [widget.userId],
        }),
      );
      if (response.statusCode == 200) {
        // Refresh the thread after sending
        await _fetchThread();
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

  Future<void> _downloadImage(String url, BuildContext context) async {
    // State variable to track download progress
    bool isDownloading = true;
    bool success = false;
    String? savedFilePath;

    try {
      // Show initial loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Downloading image...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
      );

      // Check and request storage permission (Android)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      // Get the image data with progress tracking
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        // Get downloads directory (permanent storage)
        final directory =
            Platform.isAndroid
                ? await getExternalStorageDirectory()
                : await getApplicationDocumentsDirectory();

        if (directory == null) throw Exception('Could not access storage');

        // Create better filename with timestamp
        final fileExtension = url.split('.').last;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName =
            'image_$timestamp.${fileExtension.contains('?') ? fileExtension.split('?').first : fileExtension}';
        final filePath = '${directory.path}/$fileName';

        // 5. Save the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        savedFilePath = filePath;

        // 6. Save to gallery (optional)
        try {
          await GallerySaver.saveImage(filePath);
        } catch (e) {
          debugPrint('Could not save to gallery: $e');
        }

        success = true;
      } else {
        throw Exception('Server returned status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (success && context.mounted) {
          // Show success message with option to open file
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Image downloaded successfully!'),
              action: SnackBarAction(
                label: 'OPEN',
                onPressed: () {
                  if (savedFilePath != null) {
                    OpenFile.open(savedFilePath);
                  }
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
      isDownloading = false;
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, 'refresh'),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Column(
                children: [
                  // Message List
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      itemCount: thread?.messages.length ?? 0,
                      itemBuilder: (context, index) {
                        final message = thread!.messages[index];
                        final isSentByUser = message.senderId == widget.userId;
                        final sender =
                            thread!.recipients[message.senderId.toString()];

                        return Align(
                          alignment:
                              isSentByUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            padding: const EdgeInsets.all(12),
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
                                // Attachments (Photos)
                                if (message.bpMediaIds != null &&
                                    message.bpMediaIds!.isNotEmpty)
                                  Column(
                                    children:
                                        message.bpMediaIds!.map((media) {
                                          return Column(
                                            children: [
                                              const SizedBox(height: 6),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: SizedBox(
                                                  height: 120, // Fixed height
                                                  width:
                                                      double
                                                          .infinity, // Full width
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => Scaffold(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black,
                                                                body: Stack(
                                                                  children: [
                                                                    Positioned.fill(
                                                                      child: PhotoView(
                                                                        imageProvider: NetworkImage(
                                                                          media
                                                                              .url!,
                                                                          headers: {
                                                                            'Authorization':
                                                                                'Bearer $_accessToken',
                                                                          },
                                                                        ),
                                                                        minScale:
                                                                            PhotoViewComputedScale.contained,
                                                                        maxScale:
                                                                            PhotoViewComputedScale.covered *
                                                                            2,
                                                                        backgroundDecoration: const BoxDecoration(
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top:
                                                                          MediaQuery.of(
                                                                            context,
                                                                          ).padding.top,
                                                                      right: 16,
                                                                      child: Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          // Download Button
                                                                          IconButton(
                                                                            icon: const Icon(
                                                                              Icons.download,
                                                                              color:
                                                                                  Colors.white,
                                                                            ),
                                                                            onPressed:
                                                                                () => _downloadImage(
                                                                                  media.url!,
                                                                                  context,
                                                                                ),
                                                                          ),
                                                                          // Close Button
                                                                          IconButton(
                                                                            icon: const Icon(
                                                                              Icons.close,
                                                                              color:
                                                                                  Colors.white,
                                                                            ),
                                                                            onPressed:
                                                                                () => Navigator.pop(
                                                                                  context,
                                                                                ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    child: Image.network(
                                                      media.url!,
                                                      headers: {
                                                        'Authorization':
                                                            'Bearer $_accessToken',
                                                      },
                                                      fit: BoxFit.cover,
                                                      height: 150,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                  ),

                                // Message Text
                                if (message.message.rendered.isNotEmpty)
                                  Text(
                                    _stripHtml(message.message.rendered),
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
                                    formatTimeHumanReadable(message.dateSent),
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

                  // Message Input
                  ChatInputField(onSendMessage: _sendMessage),
                ],
              ),
    );
  }
}
