import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../models/buddyboss_thread.dart';

class MessageImageGallery extends StatefulWidget {
  final List<BpMedia> mediaList;
  final String accessToken;

  const MessageImageGallery({
    super.key,
    required this.mediaList,
    required this.accessToken,
  });

  @override
  State<MessageImageGallery> createState() => _MessageImageGalleryState();
}

class _MessageImageGalleryState extends State<MessageImageGallery> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.mediaList.map((media) {
        return Column(
          children: [
            const SizedBox(height: 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          body: Stack(
                            children: [
                              Positioned.fill(
                                child: PhotoView(
                                  imageProvider: NetworkImage(
                                    media.url!,
                                    headers: {
                                      'Authorization': 'Bearer ${widget.accessToken}',
                                    },
                                  ),
                                  minScale: PhotoViewComputedScale.contained,
                                  maxScale:
                                  PhotoViewComputedScale.covered * 2,
                                  backgroundDecoration:
                                  const BoxDecoration(color: Colors.black),
                                ),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).padding.top,
                                right: 16,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.download,
                                          color: Colors.white),
                                      onPressed: () {
                                        // Handle download here
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white),
                                      onPressed: () => Navigator.pop(context),
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
                      'Authorization': 'Bearer ${widget.accessToken}',
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
    );
  }
}
