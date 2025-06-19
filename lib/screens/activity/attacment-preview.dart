import 'dart:io';
import 'package:flutter/material.dart';

class AttachmentPreview extends StatelessWidget {
  final File file;
  final int index;
  final bool isUploading;
  final Function(int index)? onRemove;
  final Future<Widget?> Function(File file)? buildVideoThumbnail;

  const AttachmentPreview({
    Key? key,
    required this.file,
    required this.index,
    required this.isUploading,
    this.onRemove,
    this.buildVideoThumbnail,
  }) : super(key: key);

  bool get isImage {
    final path = file.path.toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif'].any((ext) => path.endsWith(ext));
  }

  bool get isVideo {
    final path = file.path.toLowerCase();
    return ['.mp4', '.mov', '.avi'].any((ext) => path.endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Stack(
        children: [
          // Image preview
          if (isImage)
            Image.file(file, width: 100, height: 100, fit: BoxFit.cover)
          // Video preview
          else if (isVideo)
            FutureBuilder<Widget?>(
              future: buildVideoThumbnail?.call(file),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data ?? _fallbackVideoBox();
                }
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const CircularProgressIndicator(),
                );
              },
            )
          // Generic file preview
          else
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insert_drive_file, size: 40),
                  Text(
                    file.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          // Remove button
          if (!isUploading && onRemove != null)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                onPressed: () => onRemove?.call(index),
              ),
            ),

          // Play icon
          if (isVideo)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 30,
              ),
            ),

          // Uploading overlay
          if (isUploading)
            Container(
              width: 100,
              height: 100,
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackVideoBox() {
    return Container(
      width: 100,
      height: 100,
      color: const Color.fromARGB(255, 141, 95, 95),
      child: const Icon(Icons.videocam, size: 40),
    );
  }
}
