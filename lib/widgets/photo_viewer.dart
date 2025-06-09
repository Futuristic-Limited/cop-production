import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:APHRC_COP/services/user_upload_service.dart';
import 'dart:typed_data';
import 'package:photo_view/photo_view.dart';


class PhotoViewerScreen extends StatefulWidget {
  final int imageId;
  final String title;

  const PhotoViewerScreen({Key? key, required this.imageId, required this.title}) : super(key: key);

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late Future<Uint8List?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = UserUploadService.getUserImage(widget.imageId).then((response) => response.bodyBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF79C148),
      ),
      body: FutureBuilder<Uint8List?>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load image'));
          }

          return PhotoViewGallery.builder(
            itemCount: 1,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: MemoryImage(snapshot.data!),
                minScale: PhotoViewComputedScale.contained * 1,
                maxScale: PhotoViewComputedScale.covered * 3,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: PageController(initialPage: 0),
          );
        },
      ),
    );
  }
}
