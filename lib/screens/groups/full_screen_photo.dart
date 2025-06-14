import 'package:flutter/material.dart';
class FullScreenPhoto extends StatelessWidget {
  final String imageUrl;

  const FullScreenPhoto({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }
}