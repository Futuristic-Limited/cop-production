
import 'package:APHRC_COP/screens/messages/video.dart';
import 'package:flutter/material.dart';
import '../../models/buddyboss_thread.dart';

class MessageVideoGallery extends StatefulWidget {
  final List<BpMedia> videoList;
  final String accessToken;

  const MessageVideoGallery({
    super.key,
    required this.videoList,
    required this.accessToken,
  });

  @override
  State<MessageVideoGallery> createState() => _MessageVideoGalleryState();
}

class _MessageVideoGalleryState extends State<MessageVideoGallery> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children:
      widget.videoList.map((video) {
        // Skip if URL is null or empty
        if (video.url == null || video.url!.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 6),
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.black12,
                child: Center(
                  child: Icon(
                    Icons.videocam_off,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Video is not available or has been deleted!',
                style: TextStyle(
                  color: const Color.fromARGB(255, 17, 17, 17),
                  fontSize: 12,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => Scaffold(
                      backgroundColor: Colors.black,
                      body: Stack(
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: VideoPlayerWidget(
                                url: video.url!,
                                token: widget.accessToken,
                              ),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).padding.top,
                            right: 16,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.black12,
                    child: FutureBuilder(
                      // You might want to add a proper video thumbnail check here
                      // This is a placeholder for loading/error states
                      future: Future.delayed(
                        const Duration(milliseconds: 100),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Icon(
                              Icons.videocam_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                          );
                        }
                        return const Icon(
                          Icons.play_circle_fill,
                          size: 48,
                          color: Colors.white70,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}