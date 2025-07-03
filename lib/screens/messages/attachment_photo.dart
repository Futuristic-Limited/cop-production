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
      children:
      widget.mediaList.map((media) {
        // Skip if URL is null or empty
        if (media.url == null || media.url!.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Image is not available or has been deleted!',
                style: TextStyle(
                  color: const Color.fromARGB(255, 17, 17, 17),
                  fontSize: 12,
                ),
              ),
            ],
          );
        }

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
                        builder:
                            (_) => Scaffold(
                          backgroundColor: Colors.black,
                          body: Stack(
                            children: [
                              Positioned.fill(
                                child: PhotoView(
                                  imageProvider: NetworkImage(
                                    media.url!,
                                    headers: {
                                      'Authorization':
                                      'Bearer ${widget.accessToken}',
                                    },
                                  ),
                                  loadingBuilder:
                                      (context, event) => Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      event == null
                                          ? 0
                                          : event.cumulativeBytesLoaded /
                                          event
                                              .expectedTotalBytes!,
                                    ),
                                  ),
                                  minScale:
                                  PhotoViewComputedScale.contained,
                                  maxScale:
                                  PhotoViewComputedScale.covered *
                                      2,
                                  backgroundDecoration:
                                  const BoxDecoration(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: MediaQuery.of(context).padding.top,
                                right: 16,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.download,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Handle download here
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context),
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
                    loadingBuilder: (
                        BuildContext context,
                        Widget child,
                        ImageChunkEvent? loadingProgress,
                        ) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
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