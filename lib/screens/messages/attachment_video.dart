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
      children: widget.videoList.map((video) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
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
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.black12,
                child: const Icon(
                  Icons.play_circle_fill,
                  size: 48,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
