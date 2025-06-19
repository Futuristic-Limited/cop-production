import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<Widget> buildVideoThumbnail(File videoFile, {double size = 100}) async {
  final thumbnailPath = await VideoThumbnail.thumbnailFile(
    video: videoFile.path,
    imageFormat: ImageFormat.JPEG,
    maxHeight: size.toInt(), // Maintain square thumbnail
    quality: 75,
  );

  if (thumbnailPath != null) {
    return Image.file(
      File(thumbnailPath),
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  } else {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: const Icon(Icons.videocam, size: 40),
    );
  }
}
